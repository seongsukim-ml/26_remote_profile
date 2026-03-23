Show the current status of all project todos across the server.

---

## Step 1: Find all todo files

```bash
find /home1/irteam/data-vol1/projects -name "todo.md" -path "*/tasks/*" 2>/dev/null
```

## Step 2: Read each todo file

For each `tasks/todo.md` found, read the file contents.

## Step 3: Present a summary

Present a concise dashboard-style summary:

1. For each project with a `tasks/todo.md`:
   - **Project name** (directory name)
   - **Status**: count of completed (`[x]`) vs total (`[ ]` + `[x]`) tasks
   - **Current focus**: the first unchecked section or item (1-2 lines max)
   - **Blockers**: any items explicitly marked as blockers or stuck

2. Skip projects with no active tasks (all done or empty).

3. At the end, show a one-line summary: "X projects active, Y total open tasks"

Keep it scannable — use a table or bullet list, not walls of text.
