Check server resource health — disk, GPU, RAM, and processes. Use this when you need to assess system capacity before launching jobs, or to diagnose performance issues.

---

## Disk

```bash
# Persistent volume and temp
df -h /home1/irteam/data-vol1 /tmp 2>/dev/null
# Top-level breakdown
du -sh /home1/irteam/data-vol1/*/ 2>/dev/null | sort -rh | head -10
```

## GPU

```bash
nvidia-smi --query-gpu=index,name,memory.used,memory.total,utilization.gpu,temperature.gpu,ecc.errors.uncorrected.aggregate.total --format=csv,noheader 2>/dev/null || echo "nvidia-smi unavailable"
```

## CPU & RAM

```bash
free -h
uptime
```

## Processes

```bash
# Top memory consumers
ps aux --sort=-%mem | head -10
```

## Analysis

After collecting results, analyze and flag issues using these thresholds:

| Resource | Warning | Critical |
|----------|---------|----------|
| Persistent volume (`data-vol1`) | >80% used | >90% used |
| `/tmp` | >70% used | >90% used |
| GPU memory (any single GPU) | — | >90% used (unexpected) |
| RAM | >80% used | >90% used |
| GPU ECC errors | any uncorrected | — |
| GPU temperature | >80°C | >85°C |

Also check for:
- **Orphan GPU processes**: GPU memory occupied but no corresponding active training/experiment
- **Zombie processes**: Defunct processes that may need cleanup
- **Disk hogs**: Any single directory using >20% of total volume

If everything is healthy, report "All resources nominal" in one line.
If issues are found, list them with severity (⚠️ warning / 🔴 critical) and suggested action.
