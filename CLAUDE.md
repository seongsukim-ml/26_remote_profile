# Profile Management Guide (for AI Assistants)

This is a persistent dotfiles profile for a Kubernetes-based ML research server.
The container at `/home/irteam` is ephemeral — it gets recreated frequently.
The persistent volume at `/home1/irteam/data-vol1` survives container restarts.

## Owner

- Name: seongsukim-ml
- Email: seongsu.kim@kaist.ac.kr
- Role: ML researcher at KAIST

## Server Environment

- OS: Ubuntu 22.04 (K8s container)
- GPU: 8x NVIDIA H200 (140 GiB each)
- CPU: 2x Intel Xeon Platinum 8462Y+ (128 vCPU)
- RAM: 2 TiB
- Package manager: conda + uv (no sudo/apt access)
- Persistent storage: `/home1/irteam/data-vol1` (Lustre, 140 TiB)

### Persistent Volume Layout

```
/home1/irteam/data-vol1/
├── profile/          # Dotfiles, bootstrap, docs (this repo)
│   └── Claude Tips/  #   서버 세팅 & Claude Code 팁 (mkdocs)
├── conda/            # Conda + envs + pkgs (persistent)
├── projects/         # All code projects (각 프로젝트별 git repo)
├── datasets/         # 공용 데이터셋 (프로젝트에서 symlink로 참조)
├── www/              # Web server files
└── linux_conf/       # Legacy dotfiles (migrated → profile/)
```

## Key Rules

1. **No sudo/apt** → `conda install -c conda-forge` 또는 `uv pip install`만 사용
2. **Never commit secrets** → SSH keys, tokens, credentials은 `.gitignore`에 추가
3. **Shell config** → `bashrc.d/`에 파일 추가/수정. `~/.bashrc` 직접 수정 금지
4. **Bootstrap** → 새 컨테이너에서 `source /home1/irteam/data-vol1/profile/setup.sh` 한 번 실행

## Code Workflow

### Project Convention

- 모든 프로젝트: `/home1/irteam/data-vol1/projects/` 아래에 생성
- 프로젝트 인덱스: `/home1/irteam/data-vol1/projects/README.md`에 기록
- Conda env 이름 = 프로젝트 디렉토리 이름 (e.g., project `foo` → env `foo`)

### 프로젝트 디렉토리 구조

```
projects/<name>/
├── configs/          # YAML 설정 파일 (train.yaml, model.yaml 등)
├── data/             # symlinks → /home1/irteam/data-vol1/datasets/*
├── src/
├── requirements.txt  # uv pip freeze > requirements.txt 로 관리
├── .gitignore        # data/ 포함
└── README.md
```

### Package Management

- **conda** → Python 버전, CUDA, 시스템 라이브러리
- **uv** → Python 패키지 (`uv pip install`, pip 대신 사용)
- 환경 재현: `requirements.txt` 필수, CUDA 의존성 있으면 `environment.yaml`도 관리

### Data Management

- 데이터 저장: `/home1/irteam/data-vol1/datasets/`
- 프로젝트에서 symlink로 참조: `ln -s /home1/irteam/data-vol1/datasets/<name> data/<name>`
- 데이터셋 인덱스: `/home1/irteam/data-vol1/datasets/README.md`에 기록
- `data/`는 git에 포함하지 않음

### Config Management

- YAML 파일 기본, `configs/` 디렉토리에 용도별 분리
- 실행 시 명시적 지정: `python train.py --config configs/train.yaml`

## Workflow Orchestration

### 1. Plan Mode Default
- 3단계 이상 또는 아키텍처 결정이 필요한 작업은 반드시 plan mode 진입
- 진행이 꼬이면 즉시 STOP하고 re-plan — 밀어붙이지 않기
- 구현뿐 아니라 검증 단계에도 plan mode 활용
- 모호함을 줄이기 위해 상세 spec을 먼저 작성

### 2. Subagent Strategy
- Subagent를 적극 활용하여 main context window를 깨끗하게 유지
- 리서치, 탐색, 병렬 분석은 subagent에 위임
- 복잡한 문제는 compute를 더 투입 (subagent 병렬)
- 하나의 subagent에는 하나의 task만 부여

### 3. Self-Improvement Loop
- 사용자 교정 후 반드시 `tasks/lessons.md`에 패턴 기록
- 같은 실수를 방지하는 규칙을 스스로 작성
- 실수율이 줄어들 때까지 반복 개선
- 세션 시작 시 해당 프로젝트의 lessons 검토

### 4. Verification Before Done
- 작동을 증명하지 않고 완료 표시 금지
- 변경 사항과 main 간 동작 차이를 diff로 확인
- "시니어 엔지니어가 승인할 수준인가?" 자문
- 테스트 실행, 로그 확인, 정확성 입증

### 5. Demand Elegance (Balanced)
- 비자명한 변경에는 잠시 멈추고 "더 우아한 방법은?" 자문
- hacky하다면 "지금 아는 것을 모두 활용한 우아한 해법"을 구현
- 단순하고 명백한 수정에는 적용하지 않음 — over-engineer 금지
- 제출 전에 자기 코드에 도전

### 6. Autonomous Bug Fixing
- 버그 리포트를 받으면 바로 수정. hand-holding 요청 금지
- 로그, 에러, 실패 테스트를 추적하여 직접 해결
- 사용자의 context switching 제로 목표
- 실패하는 CI 테스트도 지시 없이 스스로 수정

## Task Management

1. **Plan First**: `tasks/todo.md`에 체크 가능한 항목으로 계획 작성
2. **Verify Plan**: 구현 시작 전 사용자와 계획 확인
3. **Track Progress**: 완료 시 항목을 즉시 체크
4. **Explain Changes**: 각 단계마다 high-level 요약 제공
5. **Document Results**: `tasks/todo.md`에 review 섹션 추가
6. **Capture Lessons**: 교정 후 `tasks/lessons.md` 업데이트

## Core Principles

- **Simplicity First**: 모든 변경을 가능한 한 단순하게. 최소한의 코드 영향
- **No Laziness**: 근본 원인을 찾기. 임시 수정 금지. 시니어 개발자 기준
- **Minimal Impact**: 필요한 부분만 수정. 버그를 도입하지 않기

## External Tools

- **Google Drive**: rclone (`gdls`, `gdcp`, `gdsync` aliases)
- **Git remote**: https://github.com/seongsukim-ml/26_remote_profile

## 세부 참조

aliases, functions, 패키지 목록, 서버 세팅 상세 등은 아래를 참조:
- Shell aliases/functions → `profile/bashrc.d/` 파일들 직접 확인
- 서버 세팅 & 팁 → `profile/Claude Tips/` (mkdocs 문서)
- 논문/발표용 Plot 가이드 → `profile/Claude Tips/04_plotting_style_guide.md`
- 패키지 설치 스크립트 → `profile/install.sh`
