Run a Dropbox operation using the `dropbox` CLI skill. The remote is scoped to SPML/data/seongsu.

If the user provided arguments, pass them directly:
```bash
/home1/irteam/data-vol1/profile/bin/dropbox $ARGUMENTS
```

If no arguments were provided, show usage by running:
```bash
/home1/irteam/data-vol1/profile/bin/dropbox help
```

Present the output to the user. For `get`/`put`/`sync` operations, confirm the paths before executing.
