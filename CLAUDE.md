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
- Package manager: conda (no sudo/apt access)
- Persistent storage: `/home1/irteam/data-vol1` (Lustre, 140 TiB)

## How This Profile Works

### Bootstrap (run once per new container)

```bash
source /home1/irteam/data-vol1/profile/setup.sh
```

This single command:
1. Symlinks `gitconfig` to `~/.gitconfig`
2. Injects a loader into `~/.bashrc` that sources all `bashrc.d/*.sh` files
3. Runs `install.sh` to install missing packages via conda
4. Loads all settings into the current shell session

### Directory Layout

```
profile/
├── setup.sh              # Bootstrap entry point (source this)
├── install.sh            # Auto-install packages via conda
├── gitconfig             # Git user config (symlinked to ~/.gitconfig)
├── CLAUDE.md             # This file — AI assistant instructions
├── README.md             # Human-readable documentation
├── .gitignore            # Excludes secrets from git
├── bin/                  # Custom scripts (added to PATH)
└── bashrc.d/             # Modular shell configs (auto-loaded)
    ├── env.sh            #   PATH, HISTSIZE, EDITOR, LANG
    ├── aliases.sh        #   Shortcuts: gs, nv, ca, ll, data, etc.
    ├── prompt.sh         #   PS1 with git branch + conda env
    └── functions.sh      #   Utilities: mkcd, ff, gpumem, extract, port
```

## Rules for Modifying This Profile

1. **Add new shell config** → Create or edit a file in `bashrc.d/`. Do not edit `~/.bashrc` directly.
2. **Add a new package** → Add it to the `PACKAGES` array in `install.sh`. Always use conda.
3. **Add a custom script** → Place it in `bin/` and `chmod +x`. It's already in PATH.
4. **Never commit secrets** → SSH keys, tokens, credentials go in `.gitignore`. Check before committing.
5. **No sudo/apt** → This container has no root access. Use `conda install -c conda-forge` for packages.
6. **Test changes** → Run `source ~/.bashrc` after editing to verify.

## Available Aliases (quick reference)

| Alias | Command | Category |
|-------|---------|----------|
| `gs` | `git status` | git |
| `gl` | `git log --oneline --graph -20` | git |
| `gd` | `git diff` | git |
| `nv` | `nvidia-smi` | GPU |
| `nvw` | `watch -n 1 nvidia-smi` | GPU |
| `ca` | `conda activate` | conda |
| `cel` | `conda env list` | conda |
| `data` | `cd /home1/irteam/data-vol1` | nav |
| `py` | `python` | python |

## Available Functions

| Function | Usage | Description |
|----------|-------|-------------|
| `mkcd` | `mkcd dirname` | mkdir + cd in one step |
| `ff` | `ff pattern` | Find files matching pattern |
| `gpumem` | `gpumem` | Show GPU memory usage per device |
| `extract` | `extract file.tar.gz` | Auto-detect and extract archives |
| `port` | `port 8080` | Check if a port is in use |

## Git Remote

- Repo: https://github.com/seongsukim-ml/26_remote_profile
- After changes, commit and push to keep the remote in sync.
