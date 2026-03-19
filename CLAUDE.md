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
- Package manager: conda + pip (no sudo/apt access)
- Persistent storage: `/home1/irteam/data-vol1` (Lustre, 140 TiB)

## How This Profile Works

### Bootstrap (run once per new container)

```bash
source /home1/irteam/data-vol1/profile/setup.sh
```

This single command:
1. Symlinks `gitconfig` → `~/.gitconfig`
2. Symlinks `tmux.conf` → `~/.tmux.conf`
3. Symlinks `vimrc` → `~/.vimrc`
4. Injects a loader into `~/.bashrc` that sources all `bashrc.d/*.sh` files
5. Runs `install.sh` to install missing packages (conda, pip, Claude Code)
6. Loads all settings into the current shell session

### Directory Layout

```
profile/
├── setup.sh              # Bootstrap entry point (source this)
├── install.sh            # Auto-install packages (conda + pip + claude)
├── gitconfig             # Git user config (→ ~/.gitconfig)
├── tmux.conf             # Tmux config (→ ~/.tmux.conf)
├── vimrc                 # Vim config (→ ~/.vimrc)
├── CLAUDE.md             # This file — AI assistant instructions
├── README.md             # Human-readable documentation
├── .gitignore            # Excludes secrets from git
├── bin/                  # Custom scripts (added to PATH)
└── bashrc.d/             # Modular shell configs (auto-loaded alphabetically)
    ├── aliases.sh        #   Shortcuts: gs, nv, ca, ll, data, tmux-*, etc.
    ├── env.sh            #   PATH, HISTSIZE, EDITOR, LANG
    ├── functions.sh      #   Utilities: mkcd, ff, gpumem, extract, port
    └── prompt.sh         #   PS1 with git branch + conda env
```

## Rules for Modifying This Profile

1. **Add new shell config** → Create or edit a file in `bashrc.d/`. Do not edit `~/.bashrc` directly.
2. **Add a new package** → Add it to `CONDA_PACKAGES` or `PIP_PACKAGES` in `install.sh`. Use conda for CLI tools, pip for Python libs.
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
tmux, htop, tree, vim

### Via pip
gpustat, wandb

### Via installer script
Claude Code CLI

## Git Remote

- Repo: https://github.com/seongsukim-ml/26_remote_profile
- After changes, commit and push to keep the remote in sync.

## Related Repository

- https://github.com/seongsukim-ml/linux_conf — Original dotfiles (bare repo style). Settings have been migrated into this profile.
