Show GPU status with burn process tracking. Quick overview of which GPUs are burning, which are used by real jobs, and which are truly idle.

---

## Steps

### 1. GPU hardware state

```bash
nvidia-smi --query-gpu=index,utilization.gpu,memory.used,memory.total,temperature.gpu --format=csv,noheader
```

### 2. Burn process state

```bash
python /home1/irteam/gpu_burn.py status 2>/dev/null || echo "No burn processes tracked"
```

### 3. All GPU processes

```bash
nvidia-smi --query-compute-apps=gpu_uuid,pid,process_name,used_gpu_memory --format=csv,noheader 2>/dev/null
```

### 4. Summary table

Combine the information and present a single table with columns:

| GPU | Util | Memory | Temp | Status |
|-----|------|--------|------|--------|

Where **Status** is one of:
- **burning** — occupied by gpu_burn.py
- **working** — occupied by a real job (not gpu_burn)
- **idle** — no processes, util 0%
- **mixed** — has both burn and real processes (shouldn't happen, flag as warning)

If any GPUs are idle, suggest running `/gpu-burn` to fill them.
If any GPUs are burning and user might want to run experiments, remind about `/gpu-free`.
