Run a Google Drive operation using the `gdrive` CLI skill.

If the user provided arguments, pass them directly:
```bash
/home1/irteam/data-vol1/profile/bin/gdrive $ARGUMENTS
```

If no arguments were provided, show usage by running:
```bash
/home1/irteam/data-vol1/profile/bin/gdrive help
```

Present the output to the user. For `get`/`put`/`sync` operations, confirm the paths before executing.
