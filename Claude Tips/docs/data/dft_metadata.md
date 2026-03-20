# DFT Calculation Metadata Template

DFT 계산은 세팅에 민감합니다. 같은 분자라도 functional, basis, grid, convergence 기준이 다르면 다른 결과가 나옵니다.
이 문제를 해결하기 위해 모든 DFT 계산 세팅을 YAML로 보존하고, Python으로 자동 캡처/검증/비교하는 유틸리티를 만들었습니다.

## 저장 위치

```
/home1/irteam/data-vol1/datasets/dft_metadata/
├── __init__.py              # from dft_metadata import DFTMetadata
├── metadata.py              # DFTMetadata 클래스 (~400 lines)
├── template.yaml            # 빈 템플릿 (모든 필드 + 주석 설명)
└── examples/                # 기존 데이터셋 메타데이터
    ├── md17_water.yaml
    ├── md17_ethanol.yaml
    ├── qh9_stable.yaml
    └── qh9_dynamic.yaml
```

## 스키마 v2.0 — 추적하는 필드들

DFT 재현성에 영향을 주는 모든 파라미터를 추적합니다.
(참고: [QCSchema](https://molssi-qc-schema.readthedocs.io), [NOMAD Metainfo](https://nomad-lab.eu), [Delta Project](https://www.science.org/doi/10.1126/science.aad3000))

### 재현성 영향도 순 (Delta Project 기반)

| 순위 | 카테고리 | 필드 | 왜 중요한가 |
|:----:|----------|------|-------------|
| 1 | **Basis** | `name`, `type`(spherical/cartesian), `ecp` | Cartesian 6d vs spherical 5d → 행렬 차원이 달라짐 |
| 2 | **XC** | `functional`, `nlc`, `omega`, `library_version` | libxc 버전에 따라 functional 구현이 달라질 수 있음 |
| 3 | **Grid** | `level`, `prune`, `radi_method`, `becke_scheme` | Quadrature scheme이 수치 적분 결과에 직접 영향 |
| 4 | **Integral** | `direct_scf_tol` | 이 값 이하의 적분을 0으로 처리 → 에너지에 영향 |
| 5 | **SCF** | `conv_tol`, `init_guess`, `lindep` | 다른 local minimum에 수렴할 수 있음 |
| 6 | **DF** | `enabled`, `auxbasis` | RI 근사 → 정확한 적분과 체계적 차이 |
| 7 | **Version** | `code`, `version` | 버그 수정/알고리즘 변경 |
| 8 | **Hardware** | `gpu.enabled`, `blas_library` | GPU Rys quadrature vs CPU libcint → rounding 차이 |

### 전체 섹션 구조

```yaml
schema_version: "2.0"

dataset:        # 이름, 타입, 소스 URL, 원소 목록
method:         # code, version, type(RKS/UKS), xc(functional/nlc/omega/library)
basis:          # name, normalized, type(spherical/cartesian), ecp, nbas, nao
scf:            # conv_tol, max_cycle, init_guess, direct_scf_tol, diis_*, lindep, ...
grid:           # level, prune, radi_method, becke_scheme, radii_adjust, atom_grid
density_fitting: # enabled, auxbasis, auxbasis_resolved, method
gpu:            # enabled, backend, gpu_model, precision, cuda/cupy version
system:         # charge, spin, multiplicity, units, symmetry
orbital:        # convention_name, atom_to_shells, max_block_size
reference_hamiltonian:  # xc_functional, init_guess (GT와 다를 수 있음!)
gradient:       # computed, grid_response
provenance:     # python/numpy/scipy/torch version, integral_library, blas_library
scf_result:     # converged, energy decomposition, HOMO/LUMO, dipole, S²
notes:          # 자유 메모
```

## 사용법

### 임포트

```python
import sys
sys.path.insert(0, "/home1/irteam/data-vol1/datasets")
from dft_metadata import DFTMetadata
```

### 1. PySCF 계산에서 자동 캡처

```python
from pyscf import gto, dft

mol = gto.Mole()
mol.build(atom='O 0 0 0; H 0 0.757 0.587; H 0 -0.757 0.587',
          basis='def2-svp', unit='ang')
mf = dft.RKS(mol)
mf.xc = 'pbe'
mf.kernel()

# 자동 캡처 — SCF 세팅, grid, 버전, 에너지 분해 등 전부 수집
meta = DFTMetadata.from_pyscf(
    mf,
    dataset_name="water",
    dataset_type="custom",
    convention_name="pyscf_def2svp",
    ref_xc="pbe",
)
meta.save("water_metadata.yaml")
print(meta.summary())
# → water | pbe/def2svp | grid=3 | pyscf=2.12.1
```

!!! tip "자동으로 캡처되는 것들"
    `from_pyscf()`는 PySCF 객체에서 다음을 자동 추출합니다:

    - XC functional, basis, grid scheme, SCF 파라미터 전부
    - Density fitting 여부 및 auxiliary basis
    - GPU 사용 여부 (gpu4pyscf 감지)
    - PySCF/NumPy/SciPy/PyTorch/CUDA 버전
    - Integral library (libcint/qcint), BLAS library (MKL/OpenBLAS)
    - SCF 수렴 정보, 에너지 분해, HOMO/LUMO, dipole moment

### 2. 기존 메타데이터 로드 & 검증

```python
meta = DFTMetadata.load("dft_metadata/examples/md17_water.yaml")
errors = meta.validate()
# → ["Missing or empty required field: method.version"]
#    (원본 데이터 생성 시 PySCF 버전이 기록되지 않음)
```

### 3. 두 데이터셋 비교

```python
water = DFTMetadata.load("dft_metadata/examples/md17_water.yaml")
qh9   = DFTMetadata.load("dft_metadata/examples/qh9_stable.yaml")

diff = water.compare_critical(qh9)
print(diff["match"])  # False
for m in diff["mismatches"]:
    print(f'  {m["field"]}: "{m["self"]}" vs "{m["other"]}"')
```

```
  method.xc.functional: "pbe, pbe" vs "b3lyp"
  grid.prune: "None" vs "nwchem_prune"
  method.version: "" vs "2.2.1"
  reference_hamiltonian.xc_functional: "pbe" vs "b3lyp"
```

### 4. 수동 작성

```python
meta = DFTMetadata.from_template()
meta.set("dataset.name", "my_dataset")
meta.set("method.xc.functional", "pbe0")
meta.set("basis.name", "cc-pvtz")
meta.set("basis.normalized", "ccpvtz")
meta.set("density_fitting.enabled", True)
meta.set("density_fitting.auxbasis", "cc-pvtz-jkfit")
meta.save("my_metadata.yaml")
```

## 단위 규약 (Unit Convention)

DFT 데이터에서 사용하는 단위를 일관되게 정리합니다. 프로젝트 간, 코드 간 단위 혼동은 흔한 버그 원인입니다.

### 기본 단위 체계

| 물리량 | 저장 단위 | SI 환산 | 비고 |
|--------|-----------|---------|------|
| **Position** | **Angstrom** (Å) | 1 Å = 10⁻¹⁰ m | PySCF 내부는 Bohr → `from_pyscf()`에서 자동 변환 |
| **Energy** | **Hartree** (Eₕ) | 1 Eₕ = 27.2114 eV | total_energy, homo, lumo, band_energy 모두 Hartree |
| **Force** | **Hartree/Bohr** | 1 Eₕ/a₀ = 51.4221 eV/Å | gradient 기본 단위 |
| **행렬 원소 (H, S, D)** | **Hartree** | | overlap S는 무차원이지만 동일 convention |
| **HOMO-LUMO gap** | **eV** | | `homo_lumo_gap`만 eV 반환 (× 27.2114) |

### 자주 쓰는 변환 상수

```python
# 에너지
HARTREE_TO_EV = 27.211386245988        # 1 Hartree → eV
HARTREE_TO_KCAL = 627.5094740631       # 1 Hartree → kcal/mol
EV_TO_KCAL = 23.060541945329           # 1 eV → kcal/mol

# 거리
BOHR_TO_ANG = 0.529177210903          # 1 Bohr → Angstrom
ANG_TO_BOHR = 1.8897259886            # 1 Angstrom → Bohr

# 힘 (gradient → force: 부호 반전)
HARTREE_BOHR_TO_EV_ANG = 51.42206313  # 1 Hartree/Bohr → eV/Å
```

### template.yaml에서의 단위 필드

```yaml
system:
  units:
    position: "angstrom"    # 좌표 단위
    energy: "hartree"       # 에너지 단위
    force: "hartree/bohr"   # 힘(gradient) 단위
```

!!! warning "단위 혼동 주의"
    - PySCF 내부 좌표는 **Bohr**이지만, `from_pyscf()`는 **Angstrom**으로 변환하여 저장
    - `mol.atom_coords()` → Bohr, `mol.atom_coords(unit="ANG")` → Angstrom
    - `homo_lumo` 속성은 **Hartree**, `homo_lumo_gap`만 **eV** — 일관되지 않으므로 사용 시 확인
    - MD17 등 외부 데이터셋은 자체 단위 규약이 있을 수 있음 → 반드시 메타데이터 확인

!!! tip "ML 학습 시 단위 선택"
    - 대부분의 MLIP (MACE, NequIP 등)은 **eV + Å** 단위를 사용
    - QHFlow2/QH9 데이터는 **Hartree + Å** (행렬) + **Hartree/Bohr** (force)
    - 학습 전 단위 통일 필수 — loss weight 해석에도 영향

### Orbital m-ordering convention

행렬(H, S, D)의 orbital index 순서는 코드마다 다르다.
자세한 내용은 [PySCF vs e3nn Convention](../projects/pyscf_e3nn_convention.md) 참조.

| Convention | l=1 (p) | l=2 (d) | 사용처 |
|------------|---------|---------|--------|
| **pyscf** | [+1,-1,0] (px,py,pz) | [0,+1,-1,+2,-2] | PySCF, QH9, QHFlow2 |
| **e3nn** | [-1,0,+1] | [-2,-1,0,+1,+2] | e3nn, eSEN, MACE |

`dft-dataset` 프로젝트의 `Molecule` dataclass는 `BasisInfo.convention` 필드에 현재 ordering을
기록하고, `mol.to_convention("e3nn")` 또는 `mol.save_npz(convention="e3nn")`으로 변환 가능.

## 발견된 주요 이슈

기존 QHFlow2 코드를 분석하며 발견한 재현성 이슈들:

!!! warning "Dual-XC Pattern (MD17)"
    MD17 데이터셋은 두 가지 다른 functional을 사용합니다:

    - **Hamiltonian/overlap/ref_ham**: `pbe` functional
    - **GT energy/force 평가**: `b3lyp` functional

    이 패턴이 코드에만 존재하고 어디에도 문서화되어 있지 않았습니다.
    QH9은 `b3lyp`을 일관되게 사용합니다.

!!! warning "Grid Pruning 차이"
    - **MD17**: `grids.prune = None` (pruning 꺼짐, 풀 grid)
    - **QH9**: `nwchem_prune` (기본값)

    같은 `grid.level=3`이라도 pruning에 따라 grid point 수와 수치 결과가 다릅니다.

!!! warning "PySCF Version Mismatch (QH9-Dynamic)"
    - 300k conformations: PySCF **2.2.1**
    - 100k conformations: PySCF **2.3.0**

    버전 차이 → libxc 버전 차이 → XC functional 구현 차이 가능성.

!!! warning "conv_tol 불일치"
    - `base_module.py`: **1e-9** (PySCF 기본값)
    - `final_processing_md17.py` CLI: **1e-7**

    어느 값으로 실제 데이터가 생성되었는지 확인 필요.

## 참고 자료

- [Delta Project (Lejaeghere et al., Science 2016)](https://www.science.org/doi/10.1126/science.aad3000) — 15개 DFT 코드 비교, ~0.8 meV/atom 차이
- [QCSchema (MolSSI)](https://molssi-qc-schema.readthedocs.io) — 양자화학 데이터 교환 표준
- [NOMAD Metainfo](https://nomad-lab.eu/prod/rae/docs/metainfo.html) — 계산 과학 메타데이터 스키마
- [GPU4PySCF (Wu et al., J. Phys. Chem. A, 2024)](https://pubs.acs.org/doi/full/10.1021/acs.jpca.4c05876) — GPU vs CPU 수치 차이 분석
- [PySCF DFT Docs](https://pyscf.org/user/dft.html) — Grid, XC, SCF 파라미터 레퍼런스
