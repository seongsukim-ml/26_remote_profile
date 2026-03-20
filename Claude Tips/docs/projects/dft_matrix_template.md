# dft-dataset — DFT Data Toolbox

Molecule dataclass, Becke grid (CPU/GPU), density 계산, convention 변환 등 DFT 데이터 처리 통합 유틸리티.

**위치**: `/home1/irteam/data-vol1/projects/dft-dataset/`
**Env**: `experiments` (CPU), `mlip` (GPU/cupy)

## 모듈 구성

| 모듈 | 역할 | PySCF 필요? |
|------|------|:-----------:|
| `molecule.py` | `Molecule` dataclass, `BasisInfo`, I/O, convention 변환 | No |
| `conventions.py` | m-ordering 정의 + reorder 엔진 (pyscf ↔ e3nn) | No |
| `grids.py` | Becke grid 생성 (Treutler + Lebedev + Becke partition), CPU/GPU | No |
| `density.py` | `DensityGrid`, ρ(r) 계산 (eval_ao + eval_rho), sampling | 계산 시 Yes |
| `solvers.py` | Eigenvalue solver (numpy/torch), density matrix, 비교 | No |
| `analysis.py` | 검증 (symmetry, trace) + 시각화 (heatmap, sparsity) | No |

## Quick Reference

### Molecule

```python
from molecule import Molecule, BasisInfo

# PySCF에서 생성
mol = Molecule.from_pyscf(mf)

# 파일 I/O
mol.save_npz("out.npz", packed=True, convention="e3nn")
mol = Molecule.load_npz("out.npz")

# Convention 변환
mol_e3nn = mol.to_convention("e3nn")

# Eigensolve + density
mol.solve_eigenproblem()         # → orbital_energies, homo, lumo
mol.compute_density_matrix()     # → density_matrix
```

### Becke Grid (PySCF-free, CPU/GPU)

```python
from grids import BeckeGrids, becke_grid_from_molecule

# 직접 생성
grid = BeckeGrids(Z, coords_bohr, use_gpu=True).build(level=3)
# grid.coords (N, 3) Bohr, grid.weights (N,)

# Molecule에서 생성 → DensityGrid (Angstrom)
dgrid = becke_grid_from_molecule(mol, level=3, use_gpu=True)
```

### Density

```python
from density import becke_grid, compute_density, DensityGrid

# PySCF-free grid 생성
grid = becke_grid(atomic_numbers=Z, positions_ang=pos, level=3, use_gpu=True)

# ρ(r) 계산 (PySCF 필요)
density = compute_density(pyscf_mol, dm, grid, xctype="LDA", use_gpu=True)

# Sampling (PySCF 불필요)
pts, rho = density.sample(n=1000, strategy="density")
n_elec = density.integrate()

# Save/load (PySCF 불필요)
density.save_npz("rho.npz")
loaded = DensityGrid.load_npz("rho.npz")
```

### Solvers

```python
from solvers import solve_gen_eigh, solve_gen_eigh_torch, compare_hamiltonians

energies, coeffs = solve_gen_eigh(H, S)                    # NumPy
energies, coeffs = solve_gen_eigh_torch(H_batch, S_batch)  # PyTorch (batched)
metrics = compare_hamiltonians(H_pred, H_true, S=S, n_electrons=n_e)
```

## 성능 (H200 GPU)

### Grid 생성 (`grids.py`)

| Molecule | Atoms | CPU | GPU | Speedup | vs PySCF |
|----------|------:|----:|----:|--------:|---------:|
| H₂O     |     3 | 3.8ms | 2.3ms | 1.7× | 12× faster |
| C₆H₆    |    12 | 151ms | 15ms | 10× | — |
| C₃₀H₆₂  |    92 | 56s | 0.88s | **63×** | — |

### Density 계산 (`density.py` + gpu4pyscf)

| Molecule | CPU LDA | GPU LDA | Speedup |
|----------|--------:|--------:|--------:|
| C₂H₆    | 69ms | 1.2ms | **56×** |
| C₆H₆    | 91ms | 2.8ms | **33×** |

## 데이터

| 디렉토리 | 내용 |
|----------|------|
| `data/lebedev_grids.npz` | Lebedev angular grid 캐시 (32종, 158KB) |
| `data/qh9_samples/` → `datasets/qh9_samples/` | QH9Stable size별 sample (26개) |

!!! warning "단위 주의"
    - 행렬/에너지: **Hartree**, force: **Hartree/Bohr**
    - 좌표: **Angstrom** (Molecule, DensityGrid) / **Bohr** (grids.py 내부)
    - `homo_lumo_gap`만 **eV**, 나머지는 Hartree
