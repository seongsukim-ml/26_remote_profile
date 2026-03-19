# Persistent Conda 설정 (컨테이너 재시작 후에도 유지)

## 문제
- 기본 conda(`/opt/conda`)는 컨테이너 임시 스토리지에 위치
- 컨테이너 재시작 시 설치한 패키지가 모두 사라짐

## 해결: data-vol1에 conda 설치

### 1. Miniforge 설치 (최초 1회)
```bash
curl -fsSL -o /tmp/Miniforge3.sh \
  https://github.com/conda-forge/miniforge/releases/latest/download/Miniforge3-Linux-x86_64.sh
bash /tmp/Miniforge3.sh -b -p /home1/irteam/data-vol1/conda
```

### 2. profile에 자동 연동
`setup.sh`에 conda 초기화 코드 추가:
```bash
CONDA_ROOT="/home1/irteam/data-vol1/conda"
if [ -d "$CONDA_ROOT" ]; then
    eval "$("$CONDA_ROOT/bin/conda" shell.bash hook)"
fi
```

`bashrc.d/env.sh`에도 동일 코드 추가하여 새 셸에서 자동 활성화.

### 3. 패키지 설치
```bash
# conda 패키지
conda install -y -c conda-forge tmux htop tree vim openssh

# pip 패키지 (torch 등)
pip install torch gpustat wandb
```

### 4. 컨테이너 재시작 후
```bash
source /home1/irteam/data-vol1/profile/setup.sh
```
이것만 실행하면 persistent conda + 모든 패키지가 즉시 사용 가능.

## 구조
```
/home1/irteam/data-vol1/
├── conda/              ← persistent conda (Miniforge)
│   ├── bin/
│   ├── lib/
│   └── ...
└── profile/
    ├── setup.sh        ← 부팅 스크립트 (conda 초기화 포함)
    ├── install.sh      ← 패키지 설치 스크립트
    └── bashrc.d/
        └── env.sh      ← 셸 환경변수 (conda hook 포함)
```
