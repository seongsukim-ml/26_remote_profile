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

## 실험으로 확인된 사실

### e3nn 양자화축 = Y축

```python
from e3nn import o3
import torch

vecs = torch.eye(3)  # x, y, z 단위벡터
sh = o3.spherical_harmonics(1, vecs, normalize=True, normalization='component')
# x-hat → m=-1 활성화 (√3, 0, 0)
# y-hat → m=0  활성화 (0, √3, 0)  ← 양자화축
# z-hat → m=+1 활성화 (0, 0, √3)
```

### 좌표 `[:,[1,2,0]]` 적용 후

```python
sh_perm = o3.spherical_harmonics(1, vecs[:, [1,2,0]], ...)
# z-hat → m=0 활성화 → 양자화축이 Z로 이동 ✓
```

### d-orbital (l=2)

```python
sh2 = o3.spherical_harmonics(2, vecs, ...)
# native:  m=0 최대 방향 = y → dy² (Y축 양자화)
# [1,2,0]: m=0 최대 방향 = z → dz² (Z축 양자화, PySCF 일치) ✓
```

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

모델이 edge의 SH 성분으로 Hamiltonian p-block을 예측할 때,
edge와 target의 축 convention이 일치해야 올바른 물리적 대응을 학습한다.

**핵심**: 두 변환 (Hamiltonian `[1,2,0]` + 좌표 `[:,[1,2,0]]`)은 **반드시 짝으로** 적용되어야 한다.
하나만 빠지면 성능 저하. 둘 다 빠지면 아래 조건부로 가능.

## s,p만 있는 basis: 변환 완전 제거 가능

d-orbital이 없는 경우 (e.g., 6-31G):

- e3nn native: (m=-1, m=0, m=+1) = (x, y, z) 방향
- PySCF native: (px, py, pz) = (x, y, z) 방향
- **물리적 방향이 이미 일치** → 양쪽 변환 모두 제거 가능, zero-cost

d-orbital이 있는 경우 (e.g., def2-SVP):

- e3nn native d_{m=0} = dy² ≠ PySCF d_{m=0} = dz²
- 좌표 `[:,[1,2,0]]` 필수 → Hamiltonian p-변환도 함께 필수

## 성능: 변환 비용과 최적화

### 현재 구현의 문제

`matrix_transform_single()`은 매 호출마다 Python loop로 index를 재계산.
**GPU에서 특히 치명적** — CUDA kernel launch가 orbital 수만큼 반복.

| 분자 | 현재 (CPU) | 현재 (GPU) | 비고 |
|------|-----------|-----------|------|
| CH4 (34 orb) | 0.18 ms | 0.66 ms | GPU가 3.7x 느림 |
| C6H6 (114 orb) | 0.54 ms | 1.91 ms | GPU가 3.5x 느림 |
| C60 (840 orb) | 2.95 ms | **12.0 ms** | GPU가 4.1x 느림 |

### 해결: Permutation index 캐싱

atom 조합별로 index를 한 번만 계산하고 재사용:

```python
def build_transform_index(atoms_list, conv):
    """한 번만 계산해서 캐싱"""
    orbitals, orbitals_order = "", []
    for a in atoms_list:
        offset = len(orbitals_order)
        orbitals += conv.atom_to_orbitals_map[a]
        orbitals_order += [i + offset for i in conv.orbital_order_map[a]]
    indices = []
    for orb in orbitals:
        offset = sum(map(len, indices))
        indices.append(torch.tensor(conv.orbital_idx_map[orb], dtype=torch.long) + offset)
    return torch.cat([indices[i] for i in orbitals_order])

# 사용
cached_idx = build_transform_index(atoms, conv).to(device)
H_transformed = H[..., cached_idx, :][..., :, cached_idx]
```

| 분자 | 현재 (GPU) | 캐싱 (GPU) | 속도 향상 |
|------|-----------|-----------|----------|
| CH4 | 0.66 ms | 0.017 ms | **39x** |
| C6H6 | 1.91 ms | 0.017 ms | **112x** |
| C60 | 12.0 ms | 0.022 ms | **545x** |

### 더 나은 방법: 전처리 시 적용

데이터셋 저장 시 변환된 행렬을 저장하면 학습 시 비용 = 0.
좌표 `[:,[1,2,0]]`만 forward pass에서 적용 (0.015 ms, 무시 가능).

## QHFlow2에서의 처리

현재 올바르게 구현되어 있음:

1. **Hamiltonian**: `orbital_conventions.py`에서 p-orbital `[1,2,0]` permute
2. **좌표**: 모델에서 `o3.spherical_harmonics(..., edge_vec[:, [1,2,0]], ...)`
3. **역변환**: `back2pyscf` convention으로 예측 → PySCF 복원

관련 파일:

- `src/common/orbital_conventions.py` — convention 정의
- `src/common/matrix_transforms.py` — 변환 엔진
- `src/models/QHFlow.py` — 좌표 permutation 적용
