Verify the following checklist before running an ML experiment.
If the user passes a config file path via $ARGUMENTS, read that config and cross-check against the checklist items.

---

## 1. Environment & Resources

- [ ] **Conda env**: Is the correct conda env activated? (`conda info --envs`)
- [ ] **GPU availability**: Check `nvidia-smi` — are GPUs free with enough memory? No other processes hogging them?
- [ ] **Disk space**: Enough free space at the output/checkpoint path? (`df -h`)
- [ ] **Package versions**: Do core libraries (`torch`, `transformers`, etc.) match config/requirements.txt?

## 2. Import & Dependency Hygiene

> Lesson from QHFlow2: top-level `import psi4` forced every downstream project to stub it. Keep imports clean from day one.

- [ ] **No top-level heavy/optional imports**: Heavy or optional libraries (`psi4`, `pyscf`, `deepspeed`, etc.) must NOT be imported at the module top level. Use lazy import inside the function/class that actually needs them.
  ```python
  # BAD
  import psi4
  class Foo:
      def calc(self): psi4.do_something()

  # GOOD
  class Foo:
      def calc(self):
          import psi4
          psi4.do_something()
  ```
- [ ] **Optional import guard**: If a module-level reference is unavoidable, use a try/except guard with a clear error message at call site.
  ```python
  try:
      import psi4
      HAS_PSI4 = True
  except ImportError:
      psi4 = None
      HAS_PSI4 = False
  ```
- [ ] **No fake stubs**: If you find `sys.modules[mod] = types.ModuleType(mod)` anywhere, that's a sign the upstream import is wrong. Fix the source, don't patch the consumer.
- [ ] **Conda-only deps documented**: Packages that can't be pip-installed (psi4, cuda-toolkit, etc.) must be listed in `environment.yaml`, not just mentioned in README.
- [ ] **Import test**: Run `python -c "from src.module import X"` for each public module — does it succeed without optional deps installed? If not, fix the imports.

## 3. Config Validation

- [ ] **Config file exists**: Does the specified config file actually exist?
- [ ] **Output/checkpoint path**: Is the save path correct? Will it overwrite a previous experiment?
- [ ] **Wandb/logging setup**: Are project name, run name, and tags intentional? Not accidentally logging to the wrong project?
- [ ] **Hyperparameter sanity**: Are lr, batch size, epochs in a reasonable range? (e.g., `lr=3e4` instead of `lr=3e-4` is a typo)
- [ ] **Random seed**: Is a seed set for reproducibility?

## 4. Data Pipeline

- [ ] **Data path validity**: Do all data paths in the config (including symlinks) exist and are accessible?
- [ ] **Data count/size**: Does the actual file count match expectations? Check for empty dirs or missing files.
- [ ] **Preprocessing consistency**: If preprocessing scripts changed, are cached results stale or conflicting?
- [ ] **Train/Val/Test split**: Are split ratios correct? Any data leakage between splits?

## 5. POC (Proof of Concept) Pitfalls

> POC answers: "Does this idea work at all?" — at minimum cost.

- [ ] **Scope to one hypothesis**: Define exactly one hypothesis to test. Testing multiple at once makes results uninterpretable.
- [ ] **Start with minimal data**: Use a 1–5% subset first. Is there a reason to use the full dataset?
- [ ] **Baseline exists**: Is there a comparison baseline? POC results without a baseline are meaningless.
- [ ] **Define success criteria upfront**: "Metric X ≥ Y means success" — decided before running. Changing criteria after is confirmation bias.
- [ ] **No premature tuning**: Don't fall into hyperparameter tuning during POC. Only verify the core idea works.
- [ ] **Design for fast failure**: If loss doesn't decrease after 1 epoch, is there an early stopping condition to abort immediately?

## 6. Dry-run Pitfalls

> Dry-run answers: "Does the full pipeline run end-to-end without errors?"
> **Rule: start from the safest config, then scale up.** CPU single-process first → single GPU → multi-GPU.

### 5a. CPU Sanity Run (break-proof baseline)

- [ ] **CPU-only first**: Run 2–3 steps on CPU (`CUDA_VISIBLE_DEVICES=""`) with a tiny dataset (2–10 samples). This eliminates CUDA/driver issues and isolates pure logic bugs.
- [ ] **Single process, num_workers=0**: Disable multiprocessing (`num_workers=0`, no DDP). Deadlocks and race conditions are invisible with parallel workers — verify correctness in serial first.
- [ ] **Small batch size**: Use `batch_size=1` or `2`. Confirm shapes, dtypes, and forward/backward pass work without OOM or dimension mismatches.
- [ ] **No amp/bf16**: Run in fp32 on CPU. Mixed precision can mask or introduce NaN — rule those out first.

### 5b. Single GPU Run

- [ ] **CUDA_VISIBLE_DEVICES**: Restrict to one GPU (`CUDA_VISIBLE_DEVICES=0`). Confirm the pipeline works on GPU before scaling.
- [ ] **Real batch size + OOM check**: Run at least 1 step with the actual batch size (including gradient accumulation) to verify GPU memory fits.
- [ ] **pin_memory=True**: Enable for CPU→GPU transfer speedup. Verify it doesn't cause issues.
- [ ] **num_workers tuning**: Increase `num_workers` (e.g., 4–8) and confirm no deadlocks or data corruption.
- [ ] **Mixed precision**: Enable amp/bf16 now and check for NaN/inf in loss and gradients.

### 5c. Multi-GPU Run (if applicable)

- [ ] **Multi-GPU compatibility**: If using DDP/FSDP, dry-run on multi-GPU. Passing on single-GPU doesn't guarantee multi-GPU works.
- [ ] **NCCL errors**: Watch for NCCL timeout or init failures — often caused by env vars or network config.

### 5d. General Dry-run Checks

- [ ] **Limit steps/epochs**: Set `max_steps=10` or `max_epochs=1` for the dry-run.
- [ ] **Checkpoint save/load**: Does the checkpoint actually get saved? Can you resume from it?
- [ ] **Logging output**: Are loss, metrics, and lr logged correctly? Any NaN or inf values?
- [ ] **Eval pipeline**: Don't dry-run only training — run eval at least once too.
- [ ] **Write permissions**: Do all save paths (checkpoints, logs, wandb) have write access?

## 7. File Hygiene

> Messy files → lost results, wasted disk, unreproducible experiments. Clean up before you create more.

- [ ] **Output directory naming**: Use a structured naming convention (e.g., `outputs/{project}/{exp_name}/{YYYY-MM-DD_HH-MM}/`). No bare `output/`, `test/`, `tmp/` dumping grounds.
- [ ] **No orphan files**: Check for leftover checkpoints, logs, or outputs from previous failed/abandoned runs. Delete or archive them before starting a new experiment.
- [ ] **Checkpoint retention policy**: Set `save_total_limit` or equivalent. Don't save every epoch — disk fills up fast with large models.
- [ ] **Log rotation**: Old logs (wandb, tensorboard, stdout) from past experiments — archived or deleted? Don't let them pile up.
- [ ] **Temp/cache cleanup**: Remove stale preprocessed caches, `__pycache__`, `.pyc`, HF cache downloads you no longer need.
- [ ] **Symlink integrity**: Data symlinks point to valid targets? Broken symlinks cause silent failures or confusing errors.
- [ ] **gitignore coverage**: Are `outputs/`, `checkpoints/`, `wandb/`, `__pycache__/`, `*.pt`, `*.bin` in `.gitignore`? Never commit model weights or logs.

## 8. Final Pre-launch Check

- [ ] **Git status**: Is the code committed? Don't run experiments from a dirty working tree — hurts reproducibility.
- [ ] **tmux/screen**: Long-running experiments must run inside tmux or screen.
- [ ] **Experiment log**: Record the hypothesis being tested and the config used (wandb notes or README).

---

After checking, report any failing items to the user with suggested fixes.
If all items pass, output: "Pre-test complete ✅ — clear to launch."
