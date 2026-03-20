# Dataset Metadata Convention

모든 데이터셋 디렉토리에 `metadata.yaml`을 필수로 배치하여, 데이터의 출처·스펙·사용법을 한 곳에서 관리한다.

## 원칙

1. **데이터셋 디렉토리 = 자기 서술적**: `metadata.yaml`만 읽으면 데이터의 핵심을 파악 가능
2. **단일 파일 원칙**: 한 데이터셋의 모든 메타 정보는 `metadata.yaml` 하나에
3. **DFT 데이터셋은 확장**: 기존 `dft_metadata/template.yaml` 스키마를 그대로 사용

## 디렉토리 구조

```
datasets/
├── README.md                    # 전체 인덱스 (테이블)
├── dft_metadata/                # DFT 메타데이터 유틸리티 (템플릿/클래스)
│   ├── template.yaml
│   └── examples/
│
├── nablaDFT/                    # ← 개별 데이터셋
│   ├── metadata.yaml            # ✅ 필수: DFT 계산 메타데이터
│   ├── README.md                # 상세 통계, 사용법
│   ├── hamiltonian_databases/   # 원본 SQLite
│   └── lmdb/                    # 변환된 LMDB
│       └── metadata.yaml        # (원본과 동일, 자동 복사)
│
├── omol25_train_4M/
│   ├── metadata.yaml            # ✅ 필수
│   └── ...
```

## metadata.yaml 스키마

### DFT 데이터셋

`dft_metadata/template.yaml` 스키마를 그대로 사용한다.
주요 섹션: `dataset`, `method`, `basis`, `scf`, `grid`, `system`, `orbital`, `notes`.

```bash
# 템플릿에서 시작
cp /home1/irteam/data-vol1/datasets/dft_metadata/template.yaml \
   /home1/irteam/data-vol1/datasets/<new_dataset>/metadata.yaml
# 필드 채우기
```

### 비-DFT 데이터셋 (MLIP, NLP, etc.)

최소 필수 필드만 포함하는 간소화 스키마:

```yaml
schema_version: "1.0"

dataset:
  name: ""                      # [REQUIRED] 데이터셋 이름
  type: ""                      # [REQUIRED] 데이터 유형 (e.g., mlip, nlp, image)
  source_url: ""                # [REQUIRED] 원본 다운로드 URL
  description: ""               # [REQUIRED] 한 줄 설명
  num_samples: null             # [OPTIONAL] 총 샘플 수
  license: ""                   # [OPTIONAL] 라이선스

data:
  format: ""                    # [REQUIRED] 저장 포맷 (lmdb, hdf5, parquet, csv, npz)
  splits: {}                    # [OPTIONAL] {split_name: num_samples}
  features: []                  # [REQUIRED] 포함된 필드 목록

units: {}                       # [OPTIONAL] {feature: unit} (e.g., {energy: eV, forces: eV/Å})

provenance:
  downloaded: ""                # [REQUIRED] 다운로드 날짜 (ISO-8601)
  paper: ""                     # [OPTIONAL] 논문 DOI/arXiv
  citation: ""                  # [OPTIONAL] BibTeX 키

notes: ""                       # [OPTIONAL] 자유 메모
```

## Workflow

### 새 데이터셋 추가 시

1. `datasets/<name>/` 디렉토리 생성
2. `metadata.yaml` 작성 (DFT면 `dft_metadata/template.yaml` 복사, 아니면 위 간소화 스키마)
3. `datasets/README.md` 인덱스에 행 추가
4. 데이터 다운로드/변환
5. 변환된 데이터가 별도 디렉토리에 있으면 `metadata.yaml` 복사

### 검증

```python
import sys
sys.path.insert(0, "/home1/irteam/data-vol1/datasets")
from dft_metadata import DFTMetadata

meta = DFTMetadata.load("datasets/nablaDFT/metadata.yaml")
errors = meta.validate()
if errors:
    print("Missing fields:", errors)
```

### 비교

```python
nabla = DFTMetadata.load("datasets/nablaDFT/metadata.yaml")
qh9 = DFTMetadata.load("datasets/dft_metadata/examples/qh9_stable.yaml")
diff = nabla.compare_critical(qh9)
for m in diff["mismatches"]:
    print(f"  {m['field']}: {m['self']} vs {m['other']}")
```

## 기존 데이터셋 현황

| Dataset | `metadata.yaml` | 타입 |
|---------|:----------------:|------|
| nablaDFT | ✅ | DFT (Psi4, ωB97X-D/def2-SVP) |
| omol25_train_4M | ❌ TODO | DFT (ωB97M-V/def2-TZVPD) |
| omol25_validation | ❌ TODO | DFT (동일) |
| qh9_samples | ❌ TODO | DFT (B3LYP/def2-SVP) |

!!! warning "TODO"
    `omol25`, `qh9_samples`에도 `metadata.yaml`을 추가해야 한다.
