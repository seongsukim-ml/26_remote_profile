# data-vol1 디렉토리 구조

## 개요

`/home1/irteam/data-vol1/`은 Kubernetes 컨테이너의 **영구 볼륨** (Lustre, 140 TiB)이다.
컨테이너(`/home/irteam`)는 재시작 시 초기화되지만, 이 볼륨은 유지된다.

모든 중요한 데이터는 반드시 이 볼륨 아래에 저장해야 한다.

## 디렉토리 구조

```
/home1/irteam/data-vol1/
│
├── profile/              # 셸 환경 설정 (dotfiles)
│   ├── setup.sh          #   부팅 시 source 하는 진입점
│   ├── install.sh        #   패키지 자동 설치 스크립트
│   ├── bashrc.d/         #   모듈별 셸 설정 (env, aliases, prompt 등)
│   ├── bin/              #   커스텀 스크립트 (PATH에 포함)
│   ├── gitconfig         #   Git 설정
│   ├── tmux.conf         #   tmux 설정
│   ├── vimrc             #   vim 설정
│   └── CLAUDE.md         #   AI 어시스턴트 가이드
│
├── conda/                # Persistent Conda (Miniforge)
│   ├── bin/              #   python, conda, uv, pip 등
│   ├── envs/             #   프로젝트별 conda 환경
│   └── pkgs/             #   패키지 캐시
│
├── projects/             # 프로젝트 코드
│   ├── README.md         #   프로젝트 인덱스
│   └── <project>/        #   개별 프로젝트 (각각 git repo)
│
├── datasets/             # 데이터셋 저장소
│   └── <dataset>/        #   개별 데이터셋
│
├── Claude Tips/          # 이 사이트 (MkDocs)
│   ├── mkdocs.yml        #   사이트 설정
│   ├── docs/             #   마크다운 원본
│   └── site/             #   빌드된 정적 사이트
│
└── www/                  # 임시 웹 파일 (테스트용)
```

## 각 디렉토리의 역할

### `profile/` — 환경 설정

컨테이너가 새로 생성될 때마다 `source profile/setup.sh` 한 번이면 전체 환경이 복원된다.
Git으로 버전 관리되어 변경 이력 추적 가능.

### `conda/` — Python 환경

시스템 conda(`/opt/conda`)가 아닌 영구 볼륨의 conda를 사용.
컨테이너 재시작 후에도 설치한 패키지가 유지됨.

- **conda**: Python 버전, 시스템 라이브러리, CUDA 관리
- **uv**: pip 대체 (10~100x 빠른 패키지 설치)

### `projects/` — 프로젝트 코드

각 프로젝트는 독립된 디렉토리 + git repo + conda 환경으로 구성.

!!! info "프로젝트 컨벤션"
    - conda 환경 이름 = 프로젝트 디렉토리 이름
    - 프로젝트 생성/삭제 시 `projects/README.md` 업데이트
    - `requirements.txt` 유지하여 환경 재현 가능하게

### `datasets/` — 데이터셋

학습/평가용 데이터를 저장하는 곳.

!!! warning "데이터셋 관리 주의"
    - 대용량 파일은 Git에 넣지 말 것
    - 데이터셋별 README.md에 출처, 버전, 전처리 방법 기록
    - 원본 데이터는 수정하지 않고 별도 전처리 디렉토리 사용

### `Claude Tips/` — 지식 베이스 (이 사이트)

Claude와의 작업에서 나온 팁을 MkDocs Material로 관리.
`mkdocs build` 후 Python HTTP 서버로 브라우저에서 열람 가능.

## 새 디렉토리를 만들어야 할 때

| 용도 | 위치 | 예시 |
|------|------|------|
| 새 프로젝트 | `projects/<name>/` | `projects/my-llm-finetune/` |
| 새 데이터셋 | `datasets/<name>/` | `datasets/ko-wiki-2026/` |
| 새 conda 환경 | `conda/envs/<name>/` | 프로젝트명과 동일하게 |
| 새 팁 문서 | `Claude Tips/docs/<category>/` | `docs/server/new_tip.md` |
| 새 셸 설정 | `profile/bashrc.d/<name>.sh` | `bashrc.d/cuda.sh` |
| 커스텀 스크립트 | `profile/bin/<name>` | `bin/backup.sh` |

!!! danger "절대 하지 말 것"
    - `/home/irteam/` (컨테이너 임시 영역)에 중요한 데이터 저장
    - `conda/` 디렉토리를 수동으로 삭제/이동
    - `profile/` 의 `.gitignore`에 등록된 시크릿 파일을 커밋
