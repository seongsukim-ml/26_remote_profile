# Remote Profile

Kubernetes 컨테이너 환경을 위한 영구 프로필 관리.
컨테이너가 재생성되어도 `/home1/irteam/data-vol1`(영구 볼륨)에 저장된 설정이 유지됩니다.

`linux_conf` 리포의 설정들이 이 프로필에 통합되었습니다.

## Quick Start

컨테이너가 새로 생성되면 **이것만 실행**:

```bash
source /home1/irteam/data-vol1/profile/setup.sh
```

이 한 줄이 아래를 자동으로 수행합니다:
- `~/.gitconfig`, `~/.tmux.conf`, `~/.vimrc` 심볼릭 링크 생성
- `~/.bashrc`에 프로필 로더 주입
- rclone config 복원 (Google Drive 자동 재연결)
- 필요한 패키지 설치 (tmux, htop, vim, rclone, gpustat, wandb, Claude Code 등)
- 현재 세션에 모든 설정 로드

## 구조

```
profile/
├── setup.sh              # 부트스트랩 (이것만 source하면 됨)
├── install.sh            # 패키지 자동 설치 (conda + pip + claude)
├── gitconfig             # git 설정 (→ ~/.gitconfig)
├── tmux.conf             # tmux 설정 (→ ~/.tmux.conf)
├── vimrc                 # vim 설정 (→ ~/.vimrc)
├── CLAUDE.md             # AI 어시스턴트용 가이드
├── README.md             # 이 파일
├── .gitignore            # 시크릿 제외 규칙
├── rclone/               # rclone config 백업 (Google Drive 등, gitignored)
├── bin/                  # 커스텀 스크립트 + rclone 바이너리 (PATH에 자동 추가)
└── bashrc.d/             # 모듈별 bash 설정 (자동 로드)
    ├── aliases.sh        #   alias (git, tmux, GPU, conda, 탐색 등)
    ├── env.sh            #   환경변수
    ├── functions.sh      #   유틸 함수
    └── prompt.sh         #   프롬프트 (git branch + conda env 표시)
```

## 설정 변경 방법

| 하고 싶은 것 | 방법 |
|-------------|------|
| alias 추가 | `bashrc.d/aliases.sh` 수정 |
| 환경변수 추가 | `bashrc.d/env.sh` 수정 |
| conda 패키지 추가 | `install.sh`의 `CONDA_PACKAGES` 배열에 추가 |
| pip 패키지 추가 | `install.sh`의 `PIP_PACKAGES` 배열에 추가 |
| 커스텀 스크립트 추가 | `bin/`에 넣고 `chmod +x` |
| tmux 설정 변경 | `tmux.conf` 수정 |
| vim 설정 변경 | `vimrc` 수정 |
| git 설정 변경 | `gitconfig` 수정 |

변경 후:
```bash
source ~/.bashrc          # 현재 세션에 반영
cd /home1/irteam/data-vol1/profile
git add -A && git commit -m "설명" && git push
```

## Google Drive (rclone)

rclone이 Google Drive에 연결되어 있습니다. 별칭과 기본 사용법:

```bash
# 별칭
gdls                              # Google Drive 루트 폴더 목록
gdcp gdrive:folder/ ./local/      # Drive → 로컬 복사
gdcp ./local/ gdrive:folder/      # 로컬 → Drive 복사
gdsync ./local/ gdrive:folder/    # 로컬 → Drive 동기화 (미러링)

# 직접 rclone 명령어
rclone ls gdrive:                 # 전체 파일 목록
rclone lsd gdrive:path/           # 특정 경로 폴더 목록
rclone copy gdrive:path/file.txt ./  # 단일 파일 다운로드
rclone sync ./data gdrive:backup/ # 양방향 동기화
rclone mount gdrive: ~/gdrive --daemon  # FUSE 마운트 (백그라운드)
```

### rclone 재인증 (토큰 만료 시)

```bash
# 로컬 PC에서 (브라우저 있는 곳):
rclone authorize "drive"

# 출력된 토큰 JSON을 서버의 rclone.conf에 업데이트:
vim ~/.config/rclone/rclone.conf
# token = {"access_token":... } 부분 교체

# 백업 갱신:
cp ~/.config/rclone/rclone.conf /home1/irteam/data-vol1/profile/rclone/rclone.conf
```

## 주의사항

- **sudo/apt 사용 불가** — 패키지는 `conda install -c conda-forge` 또는 `pip install`로 설치
- **시크릿 커밋 금지** — SSH 키, 토큰 등은 `.gitignore`에 의해 제외됨
- **`~/.bashrc` 직접 수정 금지** — 컨테이너 재생성 시 초기화됨. `bashrc.d/`에 추가할 것
