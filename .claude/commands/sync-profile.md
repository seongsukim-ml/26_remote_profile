Sync and push the profile repository to GitHub.

---

## Instructions

Run these steps sequentially:

### 1. Sync Claude Code commands → profile repo

User-level commands (`~/.claude/commands/`) may have new or updated skills that should be tracked in the profile repo. Sync them:

```bash
# Copy user-level commands to profile repo (profile repo is the source of truth for shared commands)
cp ~/.claude/commands/*.md /home1/irteam/data-vol1/profile/.claude/commands/ 2>/dev/null
```

Skip files that are project-specific (e.g., only relevant inside a specific project directory).
Profile-level commands: `gdrive.md`, `dropbox.md`, `storage.md`, `report.md`, `weekly.md`, `sync-profile.md`, `orient.md`, `pre-test.md`

### 2. Rebuild Claude Tips site (if docs changed)

Check if any `.md` files under `Claude Tips/docs/` were modified:

```bash
cd /home1/irteam/data-vol1/profile
git diff --name-only -- "Claude Tips/docs/"
```

If there are changes, rebuild:
```bash
cd /home1/irteam/data-vol1/profile/Claude\ Tips && mkdocs build 2>&1 | tail -3
```

### 3. Encrypt secrets (if changed)

```bash
cd /home1/irteam/data-vol1/profile
if git diff --name-only -- secrets/ 2>/dev/null | grep -q .; then
    bin/secrets-lock
    echo "secrets re-encrypted"
fi
```

### 4. Review & commit

```bash
cd /home1/irteam/data-vol1/profile
git status
git diff --stat
```

Show the user a summary of changes and **ask for confirmation** before committing.

Stage all relevant changes (respect `.gitignore` — secrets/, rclone/, gdrive/ are excluded):
```bash
git add -A
```

Commit with a descriptive message following the repo's style:
```bash
git commit -m "Update profile: <summary of changes>"
```

### 5. Push

```bash
cd /home1/irteam/data-vol1/profile && git push
```

### 6. Report

Print a concise summary:
- Files changed
- Commit hash
- Push status
