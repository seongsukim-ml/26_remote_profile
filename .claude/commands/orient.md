Read and internalize the philosophy, conventions, and lessons of this environment so you can work effectively from the start.

---

## Step 1: Core Philosophy

Read the profile-level CLAUDE.md — this is the master guide for how this system works and how you should behave:

```bash
cat /home1/irteam/data-vol1/profile/CLAUDE.md
```

Internalize the key rules, workflow orchestration principles, and core principles. These are non-negotiable.

## Step 2: Project Context

If the current working directory is inside a project (under `/home1/irteam/data-vol1/projects/`):

1. Read the project's `CLAUDE.md` if it exists
2. Read `tasks/lessons.md` if it exists — these are hard-won lessons from past mistakes
3. Read `tasks/todo.md` if it exists — understand what's in progress
4. Skim the project's `README.md` for purpose and structure

If not inside a project, list available projects and briefly describe each:
```bash
ls /home1/irteam/data-vol1/projects/
cat /home1/irteam/data-vol1/projects/README.md 2>/dev/null
```

## Step 3: Environment Knowledge

Read the shell configuration to understand available aliases and functions:
```bash
cat /home1/irteam/data-vol1/profile/bashrc.d/aliases.sh
cat /home1/irteam/data-vol1/profile/bashrc.d/functions.sh
```

## Step 4: Tips & Known Issues

Skim the Claude Tips docs for server-specific knowledge:
```bash
cat "/home1/irteam/data-vol1/profile/Claude Tips/docs/index.md"
```

Read any tips that seem relevant to the current task context.

## Step 5: Memory Recall

Check if there are saved memories for this project:
```bash
ls /home1/irteam/.claude/projects/-home1-irteam/memory/ 2>/dev/null
```

Read `MEMORY.md` and any relevant memory files.

---

## Output

After reading everything, present a concise briefing to the user:

1. **Environment Identity** — One-line summary of who/where/what (e.g., "ML research server, KAIST, 8xH200")
2. **Key Principles** — The 3-5 most important rules you internalized (in your own words, not copy-paste)
3. **Current Project** — What project we're in (if any), its purpose, and current state
4. **Lessons to Remember** — Any lessons from past mistakes that are relevant now
5. **Available Tools** — Relevant aliases, functions, and slash commands
6. **Resource Status** — Skip by default. Mention that `/health` is available if needed
7. **Anything Surprising** — Flag anything unusual, inconsistent, or noteworthy you found

Keep it conversational and short. The goal is to show the user that you "get it" — you understand the setup, the conventions, and the philosophy. You're ready to work.
