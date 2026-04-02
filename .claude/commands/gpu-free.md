Stop GPU burn processes to free GPUs for experiments. Use before launching training or any GPU-intensive work.

Accepts optional argument: GPU IDs to free (e.g. `0 6`). If no argument given, stops ALL burn processes.

---

## Steps

### 1. Check existing burn processes

```bash
python /home1/irteam/gpu_burn.py status 2>/dev/null || echo "No burn processes tracked"
```

If no burn processes are running, report that and stop.

### 2. Stop burn

If user provided specific GPU IDs as argument: `$ARGUMENTS`

```bash
python /home1/irteam/gpu_burn.py stop <GPU_IDS>
```

If no argument given, stop all:

```bash
python /home1/irteam/gpu_burn.py stop
```

### 3. Verify

Wait 2 seconds, then check that GPUs are actually freed:

```bash
nvidia-smi --query-gpu=index,utilization.gpu,memory.used,memory.total --format=csv,noheader
```

Report which GPUs are now free and available for experiments.
