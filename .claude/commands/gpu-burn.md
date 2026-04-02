Start GPU burn on idle GPUs to fill utilization and memory. Use when GPUs are sitting idle and you want to keep them occupied.

Accepts optional argument: GPU IDs and memory percentage (e.g. `0 6 -m 90`). If no argument given, auto-detect idle GPUs.

---

## Steps

### 1. Check current GPU state

```bash
nvidia-smi --query-gpu=index,utilization.gpu,memory.used,memory.total --format=csv,noheader,nounits
```

### 2. Check existing burn processes

```bash
python /home1/irteam/gpu_burn.py status 2>/dev/null || echo "No burn processes tracked"
```

### 3. Determine target GPUs

If the user provided specific GPU IDs as argument: `$ARGUMENTS`
- Use those GPU IDs directly.

If no argument was given:
- From step 1, identify GPUs where **utilization is 0%** AND **memory used < 1000 MiB** (truly idle).
- If no idle GPUs found, report that and stop.

### 4. Start burn

```bash
python /home1/irteam/gpu_burn.py start <GPU_IDS> -m <MEM_PCT>
```

Default memory target is 80%. If the user specified `-m`, use that value.

### 5. Verify

Wait 3 seconds, then run:

```bash
python /home1/irteam/gpu_burn.py status
```

Report which GPUs are now burning, their PID, memory usage, and utilization.
