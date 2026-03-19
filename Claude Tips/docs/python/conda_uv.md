# conda + uv 함께 사용하기

## 역할 분담
| 도구 | 역할 | 예시 |
|------|------|------|
| **conda** | Python 버전, 시스템 라이브러리, C/CUDA 의존성 | `conda install cudatoolkit`, `conda create -n myenv python=3.11` |
| **uv** | Python 패키지 설치 (pip 대체, 10~100x 빠름) | `uv pip install torch transformers` |

## 설치
```bash
# uv는 conda로 설치 (persistent conda에 포함됨)
conda install -y -c conda-forge uv
# 또는
pip install uv
```

## 기본 사용법

### conda 환경 만들기 + uv로 패키지 설치
```bash
# 1. conda로 환경 생성 (Python 버전 관리)
conda create -n myproject python=3.11 -y
conda activate myproject

# 2. uv로 패키지 설치 (pip 대신 사용)
uv pip install torch transformers datasets
uv pip install -r requirements.txt
```

### 현재 base 환경에서 uv 사용
```bash
# conda activate 된 상태에서 그냥 uv pip 사용
uv pip install 패키지명

# 특정 python을 지정할 수도 있음
uv pip install --python /home1/irteam/data-vol1/conda/bin/python 패키지명
```

## uv 주요 명령어
```bash
uv pip install 패키지         # 설치 (pip install 대비 10~100x 빠름)
uv pip install -r req.txt    # requirements.txt로 설치
uv pip uninstall 패키지       # 제거
uv pip list                  # 설치된 패키지 목록
uv pip freeze                # freeze 출력
uv pip compile req.in        # lock 파일 생성
```

## 주의사항
- CUDA 관련 패키지(cudatoolkit 등)는 conda로 설치하는 것이 안정적
- PyTorch는 `uv pip install torch`로 설치 가능 (pip 인덱스에서 CUDA 빌드 자동 선택)
- `uv pip`은 현재 활성화된 conda 환경의 site-packages에 설치됨
