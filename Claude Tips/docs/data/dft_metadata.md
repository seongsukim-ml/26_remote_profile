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
orbital:        # convention_name, atom_to_orbitals, max_block_size
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
