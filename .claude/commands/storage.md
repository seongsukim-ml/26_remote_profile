Run the `storage` command to show storage usage across all remotes and local volumes, then present the results to the user.

```bash
/home1/irteam/data-vol1/profile/bin/storage
```

Display the output as-is. If any remote fails, note which one and suggest checking `rclone config show` for debugging.
