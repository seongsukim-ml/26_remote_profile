# PySCF vs e3nn: 구면 조화 함수 Convention 차이

PySCF와 e3nn은 실수 구면 조화 함수(real spherical harmonics)의 순서/축 convention이 다르다.
Equivariant 모델로 DFT Hamiltonian을 다룰 때 반드시 이해해야 하는 부분.

## 차이 요약

### 1. p-orbital 순서 (l=1)

PySCF(libcint)만 비표준 순서를 사용한다. l≥2는 양쪽 동일.

| 패키지 | 순서 | m 값 |
|--------|------|------|
| **PySCF** | px, py, pz | m=+1, m=-1, m=0 |
| **e3nn** | (m=-1, m=0, m=+1) | 표준 m-ordering |

변환: `[1,2,0]` permutation → PySCF (px,py,pz) → e3nn (py,pz,px) = (m=-1,m=0,m=+1)

### 2. 양자화 축 (Quantization Axis)

| 패키지 | 양자화 축 | Y_1^0 ∝ |
|--------|-----------|----------|
| **PySCF** | **Z축** (표준 양자화학) | z |
| **e3nn** | **Y축** | y |

좌표를 `[:, [1,2,0]]`으로 넣으면 e3nn의 양자화축이 Z로 이동 → PySCF와 일치.

### 3. 근본 원인

e3nn v0.2.2에서 Euler angle convention을 ZYZ → YXY로 의도적으로 변경.
결과적으로 l=1 SH 출력이 (x,y,z) 순서가 되어 프로그래밍이 편해짐.

```
e3nn: (m=-1, m=0, m=+1) = (x, y, z)  ← 프로그래밍 편의
물리: (m=-1, m=0, m=+1) = (y, z, x)  ← L_z 대각화 (1920년대~)
```

이 l=1의 선택이 CG 계수를 통해 모든 l≥2에 전파되어
d_{m=0} = dy² (e3nn) vs dz² (물리학) 차이 발생.

## 축 일치의 필요성

### l=1: 축 안 맞춰도 됨 (조건부)

l=1의 real SH = Cartesian 좌표 (x,y,z) 자체. 어떤 축이 m=0이든
물리적 회전은 같은 3×3 R 행렬로 변환됨. **단, d-orbital이 없는 basis에서만**.

### l≥2: 반드시 맞춰야 함

같은 물리적 회전에 대해 D²_Y ≠ D²_Z (||차이|| = 2.83).
축을 안 맞추면 model output과 target이 다른 Wigner D로 변환되어
**equivariance 자체가 깨짐** (loss가 회전에 따라 달라짐).

### 변환을 피할 수 없는 이유

| 방법 | 코드 | 오버헤드 | 위험도 |
|------|------|---------|--------|
| `[:,[1,2,0]]` (현재) | 0줄 | ~0 ms | 없음 |
| D_block matmul | ~10줄 | +0.12 ms | 낮음 |
| e3nn 소스 수정 | ~100줄 | 0 ms | **높음** |
| e3nn fork | ~100줄 | 0 ms | 중간 |

**결론: `[:,[1,2,0]]` 한 줄이 최선.** 모든 대안이 이보다 비쌈.
e3nn의 convention 문제는 커뮤니티 전체가 인지하는 알려진 이슈.

## Equivariance는 깨지지 않는다

!!! warning "흔한 오해"
    "Convention을 안 맞추면 equivariance가 깨진다" → **틀림**.
    e3nn은 자체 convention 안에서 항상 equivariant.

실제 문제는 **물리적 대응(correspondence)의 불일치**:

```
z축 방향 edge (0,0,1)에 대해:
✓ [1,2,0] 적용: m=0 활성화 → PySCF의 pz(sigma)와 대응
✗ 그대로 입력:  m=+1 활성화 → PySCF의 px와 대응 (잘못된 매칭!)
```

**핵심**: 좌표 `[:,[1,2,0]]`과 Hamiltonian `[1,2,0]` permutation은 **세트**.
하나만 적용하면 불일치. 둘 다 적용하거나 둘 다 안 하거나.

## 성능: 변환 비용과 최적화

### Permutation index 캐싱으로 GPU 545x 향상

현재 `matrix_transform_single()`은 매 호출마다 Python loop로 index 재계산.
GPU에서 CUDA kernel launch가 누적되어 오히려 CPU보다 느림.

```python
# 한 번만 계산
cached_idx = build_transform_index(atoms, conv).to(device)
# 매번 사용
H_transformed = H[..., cached_idx, :][..., :, cached_idx]
```

| 분자 | 현재 (GPU) | 캐싱 (GPU) | 향상 |
|------|-----------|-----------|------|
| CH4 | 0.66 ms | 0.017 ms | 39x |
| C6H6 | 1.91 ms | 0.017 ms | 112x |
| C60 | 12.0 ms | 0.022 ms | **545x** |

## Tensor Expansion과 SO(2) 근사

### CG Expansion의 구조

Hamiltonian block을 CG 채널별로 분해하면:

| Block type | l_in=0 (isotropic) | 높은 l_in | 의미 |
|------------|-------------------|-----------|------|
| **Diagonal** (ii) | **98-100%** | <2% | 거의 isotropic |
| **C-H off-diag** | 90% | 10% | σ 지배적 |
| **O-H off-diag** | 56% | 44% | σ/π 혼합 |
| **H-H off-diag** | 16% | **84%** | 방향성 지배적 |

→ Diagonal: 저랭크 근사 가능. Off-diagonal: 모든 l_in 필요.

### Local frame에서 off-diagonal 대각성

Off-diagonal block을 bond 방향 local frame에서 측정하면:

| Block | local frame 대각 비율 |
|-------|---------------------|
| C-H, C-C, O-H p-p | **99.5-100%** |
| H-H p-p (근거리) | 95-99% |
| C-C d-d | **100%** |
| **p-d cross** | **~50%** (대각 근사 부적합) |

→ p-p, d-d: σ/π/δ 파라미터로 거의 완벽히 표현 가능
→ p-d cross: bandwidth 확장 필요

### SO(2) Expansion 가능성

Full CG 대신 local frame에서 m-diagonal 예측 후 Wigner D로 복원:

| Block | Full CG params | SO(2) bw=0 | SO(2) bw=1 |
|-------|---------------|------------|------------|
| p-p | 9 | 3 (67%↓) | 7 |
| d-d | 25 | 5 (80%↓) | 13 |
| p-d | 15 | 3 (80%↓) | 7 |

Diagonal block(ii)은 변경 없이 기존 CG 유지 (이미 l_in=0 지배적이라 저렴).

## dft-dataset 프로젝트: Convention 변환 유틸리티

`/home1/irteam/data-vol1/projects/dft-dataset/src/conventions.py`에
convention 정의와 변환 로직이 독립 모듈로 구현되어 있다.

### m-ordering 정의

| Convention | l=0 | l=1 | l=2 | l=3 |
|------------|-----|-----|-----|-----|
| **pyscf** | [0] | [+1,-1,0] | [0,+1,-1,+2,-2] | [0,+1,-1,+2,-2,+3,-3] |
| **e3nn** | [0] | [-1,0,+1] | [-2,-1,0,+1,+2] | [-3,-2,-1,0,+1,+2,+3] |

l=1만 다르고 (PySCF 비표준), l≥2는 순서 자체가 다름 (interleaved vs ascending).

### 핵심 API

```python
from conventions import get_m_order, shell_reorder, build_reorder_indices

# Shell 단위 permutation (캐싱됨)
get_m_order("pyscf", 1)              # [1, -1, 0]
shell_reorder(1, "pyscf", "e3nn")    # (1, 2, 0)
shell_reorder(2, "pyscf", "e3nn")    # (4, 2, 0, 1, 3)

# 분자 전체 reorder index
idx = build_reorder_indices(
    atomic_numbers,
    atom_to_shells={"1": "ssp", "8": "sssppd"},
    src="pyscf", dst="e3nn",
)
H_e3nn = H_pyscf[np.ix_(idx, idx)]
```

### Molecule 통합 사용

```python
from molecule import Molecule, BasisInfo

mol = Molecule.load_npz("sample.npz")
mol.basis_info = BasisInfo.from_name("def2-svp")  # convention="pyscf" (기본)

# 변환
mol_e3nn = mol.to_convention("e3nn")

# 저장 시 변환
mol.save_npz("out.npz", convention="e3nn")          # e3nn으로 변환 후 저장
mol.save_npz("out.npz", packed=True, convention="e3nn")  # 압축 + 변환
```

!!! tip "BasisInfo에 convention이 저장됨"
    `save_npz()`/`load_npz()` 시 `basis_info.convention` 필드가 함께 저장되므로,
    로드할 때 현재 데이터가 어느 convention인지 항상 알 수 있다.

## 관련 파일

### dft-dataset (재사용 가능 유틸리티)

| 파일 | 역할 |
|------|------|
| `projects/dft-dataset/src/conventions.py` | convention 정의 + reorder 엔진 |
| `projects/dft-dataset/src/molecule.py` | `Molecule.to_convention()`, `BasisInfo` |

### QHFlow2 (프로젝트 내부용)

| 파일 | 역할 |
|------|------|
| `projects/QHFlow2/src/common/orbital_conventions.py` | convention 정의 |
| `projects/QHFlow2/src/common/matrix_transforms.py` | 변환 엔진 |
| `projects/QHFlow2/src/models/QHFlow.py` | 좌표 permutation |
| `projects/QHFlow2/src/models/layers.py` | Expansion 클래스 (CG tensor product) |
| `projects/QHFlow2/src/utils.py` | 간단한 Expansion (weight 없는 버전) |
