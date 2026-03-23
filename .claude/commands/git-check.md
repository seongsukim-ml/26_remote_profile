Check the git and GitHub sync status of all active projects.

---

## Step 1: Scan All Projects

For each directory under `/home1/irteam/data-vol1/projects/`, run the following checks:

```bash
for dir in /home1/irteam/data-vol1/projects/*/; do
  name=$(basename "$dir")
  echo "=== $name ==="

  # Check if git repo
  if [ ! -d "$dir/.git" ]; then
    echo "  ❌ Not a git repo"
    echo ""
    continue
  fi

  cd "$dir"

  # Current branch
  branch=$(git branch --show-current 2>/dev/null || echo "DETACHED")
  echo "  Branch: $branch"

  # Remote
  remote=$(git remote get-url origin 2>/dev/null || echo "NONE")
  echo "  Remote: $remote"

  # Uncommitted changes
  changes=$(git status --short | wc -l)
  if [ "$changes" -gt 0 ]; then
    echo "  ⚠️  Uncommitted changes: $changes files"
  else
    echo "  ✅ Working tree clean"
  fi

  # Unpushed commits (fetch first to compare)
  git fetch origin --quiet 2>/dev/null
  ahead=$(git rev-list --count origin/$branch..HEAD 2>/dev/null || echo "?")
  behind=$(git rev-list --count HEAD..origin/$branch 2>/dev/null || echo "?")
  if [ "$ahead" != "0" ] || [ "$behind" != "0" ]; then
    echo "  ⚠️  Ahead: $ahead, Behind: $behind"
  else
    echo "  ✅ In sync with remote"
  fi

  echo ""
done
```

## Step 2: Large File Check

For each git repo, check if any tracked files exceed 50 MB (GitHub's warning threshold):

```bash
for dir in /home1/irteam/data-vol1/projects/*/; do
  [ ! -d "$dir/.git" ] && continue
  name=$(basename "$dir")
  cd "$dir"
  large=$(git ls-files -z | xargs -0 -I{} sh -c 'size=$(stat -c%s "{}" 2>/dev/null || echo 0); if [ "$size" -gt 52428800 ]; then echo "  {} ($(numfmt --to=iec $size))"; fi' 2>/dev/null)
  if [ -n "$large" ]; then
    echo "=== $name: Large tracked files ==="
    echo "$large"
    echo ""
  fi
done
```

## Step 3: Gitignore Coverage

For each git repo, check for common files/dirs that should typically be ignored but are tracked or untracked:

```bash
for dir in /home1/irteam/data-vol1/projects/*/; do
  [ ! -d "$dir/.git" ] && continue
  name=$(basename "$dir")
  cd "$dir"
  issues=""
  # Check for tracked files that should be ignored
  for pattern in "*.pt" "*.ckpt" "*.lmdb" "__pycache__" ".venv" "lightning_logs" "wandb"; do
    found=$(git ls-files "$pattern" 2>/dev/null | head -3)
    if [ -n "$found" ]; then
      issues="${issues}  🔴 Tracked but should be ignored: $pattern\n"
    fi
  done
  if [ -n "$issues" ]; then
    echo "=== $name: Gitignore issues ==="
    printf "$issues"
    echo ""
  fi
done
```

## Step 4: GitHub Visibility Check

Verify that repos are set to the expected visibility:

```bash
gh repo list seongsukim-ml --limit 30 --json name,visibility 2>/dev/null
```

---

## Output

Present a summary table:

| Project | Branch | Remote | Status | Issues |
|---------|--------|--------|--------|--------|

For each project, show:
- **Branch**: current branch name
- **Remote**: GitHub repo name (or "NONE" / "not a git repo")
- **Status**: ✅ clean & synced / ⚠️ uncommitted / ⚠️ unpushed / 🔴 no remote
- **Issues**: large tracked files, gitignore gaps, visibility mismatches

At the end, provide:
1. **Action items** — specific commands to fix any issues found
2. **One-line summary** — e.g., "7/9 repos clean, 2 have unpushed changes"
