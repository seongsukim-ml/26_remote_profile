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
├── profile/          # Dotfiles & bootstrap (this repo)
├── conda/            # Conda installation + envs + pkgs (persistent)
├── projects/         # All code projects (각 프로젝트별 git repo)
├── datasets/         # 공용 데이터셋 (프로젝트에서 symlink로 참조)
├── www/              # Web server files
├── linux_conf/       # Legacy dotfiles (migrated → profile/)
└── Claude Tips/      # Claude Code 사용 팁 모음
```

- `projects/`, `datasets/`에는 각각 README.md가 있어 인덱스 역할을 함
- 새 프로젝트/데이터셋 추가 시 해당 README.md를 업데이트할 것

## How This Profile Works

### Bootstrap (run once per new container)

```bash
source /home1/irteam/data-vol1/profile/setup.sh
```

This single command:
1. Symlinks `gitconfig` → `~/.gitconfig`
2. Symlinks `tmux.conf` → `~/.tmux.conf`
3. Symlinks `vimrc` → `~/.vimrc`
4. Symlinks `condarc` → `~/.condarc` (persistent envs_dirs/pkgs_dirs)
5. Restores rclone config (Google Drive reconnection)
6. Injects a loader into `~/.bashrc` that sources all `bashrc.d/*.sh` files
7. Runs `install.sh` to install missing packages (conda, pip, rclone, Claude Code)
8. Loads all settings into the current shell session

### Directory Layout

```
profile/
├── setup.sh              # Bootstrap entry point (source this)
├── install.sh            # Auto-install packages (conda + pip + claude)
├── gitconfig             # Git user config (→ ~/.gitconfig)
├── tmux.conf             # Tmux config (→ ~/.tmux.conf)
├── vimrc                 # Vim config (→ ~/.vimrc)
├── condarc               # Conda config (→ ~/.condarc, persistent envs/pkgs dirs)
├── CLAUDE.md             # This file — AI assistant instructions
├── README.md             # Human-readable documentation
├── .gitignore            # Excludes secrets from git
├── rclone/               # rclone config backup (Google Drive tokens, gitignored)
├── bin/                  # Custom scripts + rclone binary (added to PATH)
└── bashrc.d/             # Modular shell configs (auto-loaded alphabetically)
    ├── aliases.sh        #   Shortcuts: gs, nv, ca, ll, data, tmux-*, etc.
    ├── env.sh            #   PATH, HISTSIZE, EDITOR, LANG
    ├── functions.sh      #   Utilities: mkcd, ff, gpumem, extract, port
    └── prompt.sh         #   PS1 with git branch + conda env
```

## Rules for Modifying This Profile

1. **Add new shell config** → Create or edit a file in `bashrc.d/`. Do not edit `~/.bashrc` directly.
2. **Add a new package** → Add it to `CONDA_PACKAGES` or `PIP_PACKAGES` in `install.sh`. Use conda for CLI/system tools, `uv pip install` for Python libs.
3. **Add a custom script** → Place it in `bin/` and `chmod +x`. It's already in PATH.
4. **Change tmux/vim config** → Edit `tmux.conf` or `vimrc` directly. Changes take effect on next tmux/vim start.
5. **Never commit secrets** → SSH keys, tokens, credentials go in `.gitignore`. Check before committing.
6. **No sudo/apt** → This container has no root access. Use `conda install -c conda-forge` or `pip install`.
7. **Test changes** → Run `source ~/.bashrc` after editing to verify.

## Available Aliases (quick reference)

| Alias | Command | Category |
|-------|---------|----------|
| `gs` | `git status` | git |
| `gl` | `git log --oneline --graph -20` | git |
| `gd` | `git diff` | git |
| `gb` | `git branch` | git |
| `ga` | `git add` | git |
| `gc` | `git commit` | git |
| `gp` | `git push` | git |
| `nv` | `nvidia-smi` | GPU |
| `nvw` | `watch -n 1 nvidia-smi` | GPU |
| `watch-gpu` | `watch -d -n 0.5 nvidia-smi` | GPU |
| `ca` | `conda activate` | conda |
| `cda` | `conda deactivate` | conda |
| `cel` | `conda env list` | conda |
| `data` | `cd /home1/irteam/data-vol1` | nav |
| `py` | `python` | python |
| `tmux-kill` | `tmux kill-session -t` | tmux |
| `tmux-gpu` | `tmux at -t GPU` | tmux |
| `tmux-jupyter` | `tmux at -t jupyter` | tmux |
| `gdls` | `rclone lsd gdrive:` | gdrive |
| `gdcp` | `rclone copy` | gdrive |
| `gdsync` | `rclone sync` | gdrive |

## Available Functions

| Function | Usage | Description |
|----------|-------|-------------|
| `mkcd` | `mkcd dirname` | mkdir + cd in one step |
| `ff` | `ff pattern` | Find files matching pattern |
| `gpumem` | `gpumem` | Show GPU memory usage per device |
| `extract` | `extract file.tar.gz` | Auto-detect and extract archives |
| `port` | `port 8080` | Check if a port is in use |

## Installed Packages

### Via conda
tmux, htop, tree, vim, openssh, uv

### Via uv (pip)
gpustat, wandb, torch

### Via direct download
rclone (Google Drive / cloud storage)

### Via installer script
Claude Code CLI

## Git Remote

- Repo: https://github.com/seongsukim-ml/26_remote_profile
- After changes, commit and push to keep the remote in sync.

## Code Workflow

### Project Location

- All projects live under `/home1/irteam/data-vol1/projects/`
- Each project is a subdirectory with its own git repo and README
- The project index is maintained in `/home1/irteam/data-vol1/projects/README.md` — update it when creating or archiving a project

### Conda + uv 패키지 관리

- Conda: `/home1/irteam/data-vol1/conda/` (persistent, 컨테이너 재시작 후에도 유지)
- **conda** → Python 버전, 시스템 라이브러리, CUDA 의존성 관리 (`conda install -c conda-forge`)
- **uv** → Python 패키지 설치 (`uv pip install`, pip 대비 10~100x 빠름)
- pip 대신 `uv pip install`을 기본으로 사용
- conda 환경별로 uv가 해당 환경의 site-packages에 설치함

#### 환경 생성 패턴
```bash
conda create -n myproject python=3.11 -y
conda activate myproject
uv pip install torch transformers   # pip 대신 uv 사용
uv pip install -r requirements.txt
```

#### 환경 관리 규칙
- Create project-specific envs under `/home1/irteam/data-vol1/conda/envs/` so they persist
- Naming convention: env name matches project directory name (e.g., project `foo` → env `foo`)
- CUDA 관련 패키지(cudatoolkit 등)는 conda로 설치
- 일반 Python 패키지는 uv로 설치

### Data Management

- 데이터는 프로젝트 밖의 공용 디렉토리에 저장: `/home1/irteam/data-vol1/datasets/`
- 프로젝트에서는 심볼릭 링크로 참조: `ln -s /home1/irteam/data-vol1/datasets/<dataset_name> <project>/data/<dataset_name>`
- 이렇게 하면 여러 프로젝트가 동일 데이터를 중복 없이 공유 가능
- 데이터는 git에 포함하지 않음 — 프로젝트 `.gitignore`에 `data/` 추가
- 새 데이터셋 추가 시 `/home1/irteam/data-vol1/datasets/README.md`에 데이터셋 설명 기록

#### 프로젝트 디렉토리 구조 예시
```
projects/myproject/
├── configs/          # YAML config files
├── data/             # symlinks → /home1/irteam/data-vol1/datasets/*
│   └── my_dataset -> /home1/irteam/data-vol1/datasets/my_dataset
├── src/
├── requirements.txt
├── .gitignore        # data/ 포함
└── README.md
```

### Config Management

- 프로젝트 설정은 YAML 파일을 기본으로 사용
- 프로젝트 루트에 `configs/` 디렉토리를 두고 용도별로 분리 (e.g., `configs/train.yaml`, `configs/model.yaml`)
- 실행 시 config 파일을 명시적으로 지정: `python train.py --config configs/train.yaml`

### Package Reproducibility

- 각 프로젝트에 `requirements.txt`를 유지하여 환경 재현 가능하게 관리
- 패키지 추가/변경 후 반드시 export: `uv pip freeze > requirements.txt`
- 환경 재생성 시: `conda create -n <project> python=<ver> -y && conda activate <project> && uv pip install -r requirements.txt`
- CUDA/시스템 의존성이 있으면 `environment.yaml`도 함께 관리:
  ```bash
  conda env export --from-history > environment.yaml
  ```

## Google Drive (rclone)

- Remote name: `gdrive` (configured in rclone)
- Config backup: `profile/rclone/rclone.conf` (gitignored, persisted on volume)
- Use `gdls`, `gdcp`, `gdsync` aliases or `rclone` directly
- If token expires: re-authorize on local PC with `rclone authorize "drive"`, then update `~/.config/rclone/rclone.conf` and backup to `profile/rclone/`

## Related Repository

- https://github.com/seongsukim-ml/linux_conf — Original dotfiles (bare repo style). Settings have been migrated into this profile.
