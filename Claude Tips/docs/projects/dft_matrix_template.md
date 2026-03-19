# DFT Matrix Template

Hamiltonian (H), Overlap (S), Density Matrix (D)를 일관되게 다루기 위한 재사용 가능 템플릿.

- **위치**: `/home1/irteam/data-vol1/templates/dft_matrix_template.py`
- **QHFlow2 호환**: packed upper triangle, LMDB 포맷과 동일한 convention

## 핵심 기능

| 기능 | 설명 |
|------|------|
| `pack_upper_triangle` / `unpack_upper_triangle` | 대칭 행렬 ↔ 1D packed array |
| `solve_gen_eigh(H, S)` | Generalized eigenvalue problem HC = SCε |
| `build_density_matrix(C, n_e)` | MO coefficients → density matrix (RKS) |
| `DFTMatrixHandler` | 로드/저장/분석/시각화 통합 클래스 |
| `compare_matrices(H_pred, H_true)` | 모델 평가 (MAE, RMSE, gap error) |
| `solve_gen_eigh_torch(H, S)` | Batched PyTorch 버전 (differentiable) |

## DFTMatrixHandler 사용법

### PySCF에서 생성

```python
from pyscf import gto, dft
from dft_matrix_template import DFTMatrixHandler

mol = gto.M(atom='H 0 0 0; H 0 0 0.74', basis='def2-svp')
mf = dft.RKS(mol, xc='PBE').run()

handler = DFTMatrixHandler.from_pyscf(mf)
handler.summary()
handler.save("h2.npz")
```

### 파일에서 로드

```python
handler = DFTMatrixHandler.from_npz("h2.npz")
handler.solve_eigenvalues()
handler.compute_density_matrix()
```

### QHFlow2 LMDB 데이터에서 로드

```python
handler = DFTMatrixHandler.from_packed(
    atoms=atoms,
    pos=pos,
    packed_H=packed_hamiltonian,
    n_H=h_dim,
    packed_S=packed_overlap,
    n_S=s_dim,
)
```

## 분석 기능

```python
# 기본 정보
handler.summary()          # 전체 요약 출력
handler.homo_lumo          # (HOMO, LUMO) in Hartree
handler.homo_lumo_gap      # Gap in eV

# 검증
handler.check_symmetry()   # H, S, D 대칭성 확인
handler.check_trace()      # Tr(DS) = n_electrons 확인
handler.check_idempotency()  # D @ S @ D ≈ D 확인

# 에너지
handler.band_energy()      # Tr(H @ D) — one-electron energy
```

## 시각화

```python
import matplotlib.pyplot as plt

fig, axes = plt.subplots(1, 3, figsize=(15, 4))
handler.plot_matrix("H", ax=axes[0])     # Hamiltonian heatmap
handler.plot_matrix("S", ax=axes[1])     # Overlap heatmap
handler.plot_sparsity("H", ax=axes[2])   # Sparsity pattern
plt.tight_layout()

# Orbital energy level diagram
handler.plot_eigenvalues()
```

## 모델 평가

```python
from dft_matrix_template import compare_matrices

metrics = compare_matrices(H_pred, H_true, S=S, n_electrons=n_e)
# → {'mae_H': ..., 'rmse_H': ..., 'max_error_H': ...,
#    'mae_energies': ..., 'gap_error_eV': ...}
```

## PyTorch (학습/추론)

```python
from dft_matrix_template import numpy_to_torch, solve_gen_eigh_torch

tensors = numpy_to_torch(handler, device="cuda")
energies, coeffs = solve_gen_eigh_torch(tensors["H"], tensors["S"])
```

!!! info "Eigenvalue solver method"
    `solve_gen_eigh`는 `"eigh"` (S^{-1/2} 변환, 기본값)과 `"cholesky"` 두 가지 방법을 지원.
    S의 condition number가 클 때는 eigh가 더 안정적이고, 정상적인 경우 cholesky가 약간 빠름.

!!! warning "단위 주의"
    - 행렬 원소: **Hartree**
    - 좌표: **Angstrom** (PySCF 내부는 Bohr → `from_pyscf`에서 자동 변환)
    - `homo_lumo_gap`만 **eV**로 반환, 나머지는 Hartree
