# Remote Profile

Kubernetes 컨테이너 환경을 위한 영구 프로필 관리.
컨테이너가 재생성되어도 `/home1/irteam/data-vol1`(영구 볼륨)에 저장된 설정이 유지됩니다.

## Quick Start

컨테이너가 새로 생성되면 **이것만 실행**:

```bash
source /home1/irteam/data-vol1/profile/setup.sh
```

이 한 줄이 아래를 자동으로 수행합니다:
- `~/.gitconfig` 심볼릭 링크 생성
- `~/.bashrc`에 프로필 로더 주입
- 필요한 패키지 설치 (tmux, htop, tree, claude 등)
- 현재 세션에 모든 설정 로드

## 구조

```
profile/
├── setup.sh              # 부트스트랩 (이것만 source하면 됨)
├── install.sh            # 패키지 자동 설치 (conda 기반)
├── gitconfig             # git 사용자 설정
├── CLAUDE.md             # AI 어시스턴트용 가이드
├── README.md             # 이 파일
├── .gitignore            # 시크릿 제외 규칙
├── bin/                  # 커스텀 스크립트 (PATH에 자동 추가)
└── bashrc.d/             # 모듈별 bash 설정 (자동 로드)
    ├── env.sh            #   환경변수
    ├── aliases.sh        #   alias 모음
    ├── prompt.sh         #   프롬프트 (git branch + conda env 표시)
    └── functions.sh      #   유틸 함수
```

## 설정 변경 방법

| 하고 싶은 것 | 방법 |
|-------------|------|
| alias 추가 | `bashrc.d/aliases.sh` 수정 |
| 환경변수 추가 | `bashrc.d/env.sh` 수정 |
| 패키지 추가 | `install.sh`의 `PACKAGES` 배열에 추가 |
| 커스텀 스크립트 추가 | `bin/`에 넣고 `chmod +x` |
| git 설정 변경 | `gitconfig` 수정 |

변경 후:
```bash
source ~/.bashrc          # 현재 세션에 반영
cd /home1/irteam/data-vol1/profile
git add -A && git commit -m "설명" && git push
```

## 주의사항

- **sudo/apt 사용 불가** — 패키지는 반드시 `conda install -c conda-forge`로 설치
- **시크릿 커밋 금지** — SSH 키, 토큰 등은 `.gitignore`에 의해 제외됨
- **`~/.bashrc` 직접 수정 금지** — 컨테이너 재생성 시 초기화됨. `bashrc.d/`에 추가할 것
