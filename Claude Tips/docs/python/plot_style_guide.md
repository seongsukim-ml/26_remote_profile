# Plot Style Guide

QHFlow2 `_asset/` 노트북들에서 추출한 시각화 컨벤션 정리.
새 프로젝트에서 그림을 그릴 때 이 가이드를 따른다.

---

## Font

### Primary: DIN

```python
from pathlib import Path
from matplotlib import font_manager as fm
import matplotlib.pyplot as plt

FONT_DIR = Path("/home1/irteam/data-vol1/projects/QHFlow2/_asset/font")  # adjust per project

for f in FONT_DIR.glob("*.[ot]tf"):
    fm.fontManager.addfont(str(f))

# Priority: DIN_2014 > DIN Expanded > DIN Regular > fallback
plt.rcParams["font.family"] = "DIN_2014"  # or detected name
plt.rcParams["font.sans-serif"] = ["DIN_2014", "Arial", "Helvetica", "DejaVu Sans"]
plt.rcParams["axes.unicode_minus"] = False
```

### Font Size Convention

| Element        | Publication (small fig) | Exploration (large fig) |
|----------------|:-----------------------:|:-----------------------:|
| Tick labels    | 7–8 pt                  | 10–12 pt               |
| Axis labels    | 8–9 pt, **bold**        | 12 pt                  |
| Annotations    | 6.5–7 pt                | 10 pt                  |
| Legend          | 6.5–8 pt                | 10–12 pt               |
| Title          | 10–14 pt                | 14–18 pt               |

!!! tip "Reusable snippet"
    ```python
    FS = {"label": 8, "tick": 7, "annot": 7}  # publication defaults
    ```

---

## Color Palette

### Primary Colors

```python
COLORS = {
    "blue":   "#5384EC",
    "yellow": "#F5B025",
    "red":    "#D85140",
}
```

### Extended Palette

```python
COLORS_EXT = {
    "green":  "#009354",
    "orange": "#D55E00",
    "purple": "#9C27B0",
    "teal":   "#4E79A7",
    "darkred":"#C70600",
}
```

### Per-model Colors (QHFlow2 specific)

```python
MODEL_COLORS = {
    "QHFlow2":       "#E87A6B",
    "MLIP-Nequip":   "#B0A9E6",
    "MLIP-Gemnet-T": "#A5CF9F",
    "MLIP-Dimenet":  "#C0C0C0",
}
```

### Bar Chart / SCF Colors

```python
BAR_COLORS = ["#757575", "#C45C1C", "#5DA7E2"]
```

### Matrix Colormap

- Hamiltonian/overlap matrix: `cmap="bwr"` (blue-white-red), symmetric `vmin=-max_val, vmax=max_val`
- Correlation matrix: `cmap="coolwarm"`, `vmin=-1, vmax=1`

---

## Figure Size

### Publication Figures (small, single-column)

```python
ratio = 1.05  # tweak per figure
fig, ax = plt.subplots(figsize=(2.3 * ratio, 1.45 * ratio))
```

### Multi-panel

```python
# Side-by-side (e.g., per-molecule comparison)
fig, axes = plt.subplots(1, n, figsize=(2.2 * n * ratio, 1.55 * ratio), sharey=True)

# 2x2 dissociation curves
fig, axes = plt.subplots(2, 2, figsize=(5.0 * ratio, 2.8 * ratio))
```

### Bar Charts (wide)

```python
ratio = 0.8
fig, axes = plt.subplots(1, 3, figsize=(16 * ratio, 3.5 * ratio))
```

### Exploration / Debugging

```python
fig, ax = plt.subplots(figsize=(10, 6))   # quick look
fig, axes = plt.subplots(1, 3, figsize=(18, 5))  # parity plots
```

---

## Axis & Grid

### Ticks

```python
ax.tick_params(direction="out", top=False, right=False, labelsize=FS["tick"])
ax.tick_params(which="major", length=2.25)
ax.tick_params(which="minor", length=1.25)
```

### Grid

```python
# Horizontal grid only (default)
ax.yaxis.grid(True, which="major", ls=":", alpha=0.9, linewidth=0.6, zorder=0)
ax.xaxis.grid(False)
ax.grid(False, which="minor")
```

!!! note
    Vertical grid lines are almost never used. Keep the x-axis clean.

### Spines

```python
for spine in ax.spines.values():
    spine.set_linewidth(0.75)
```

### Log Scale

```python
from matplotlib import ticker

ax.set_xscale("log")
ax.set_yscale("log")

# Minor ticks
ax.xaxis.set_minor_locator(ticker.LogLocator(base=10, subs=np.arange(2, 10)))
ax.xaxis.set_minor_formatter(ticker.NullFormatter())
```

---

## Line & Marker

### Data Lines

```python
# "Ours" — bold, high contrast
ax.plot(x, y, "-o", color=COLORS["blue"], linewidth=1.5, markersize=3.2, alpha=0.72, zorder=3)

# Others — thinner, lower contrast
ax.plot(x, y, "--s", color="#B0A9E6", linewidth=0.95, markersize=2.8, alpha=0.5, zorder=2)
```

### Line Style Convention

| Model / Series | Style |
|---------------|-------|
| Ours          | `-` (solid) |
| Baseline 1    | `--` (dashed) |
| Baseline 2    | `-.` (dash-dot) |
| Baseline 3    | `:` (dotted) |

### Reference Lines

```python
# Perfect prediction (parity)
ax.plot(lim, lim, "r--", lw=2, label="Perfect prediction")

# Threshold
ax.axhline(90, color="r", linestyle="--", lw=1, alpha=0.7, label="90%")
```

---

## Legend

```python
legend = ax.legend(
    framealpha=1,
    frameon=True,
    edgecolor="black",
    fontsize=FS["annot"],
)
legend.get_frame().set_linewidth(0.6)

# "Ours" label bold
for text in legend.get_texts():
    if "QHFlow" in text.get_text():
        text.set_fontweight("bold")
```

### Multi-subplot Shared Legend

```python
fig.legend(
    loc="lower center",
    bbox_to_anchor=(0.5, -0.10),
    ncol=3,
    fontsize=12,
    frameon=False,
)
```

---

## Save

### Publication (PDF, 600 DPI)

```python
fig.savefig("figure.pdf", dpi=600, bbox_inches="tight", pad_inches=0.02)
```

### Quick Preview (PNG, 300 DPI)

```python
fig.savefig("figure.png", dpi=300, bbox_inches="tight", facecolor="white")
```

!!! warning "Always"
    - `bbox_inches="tight"` to avoid clipped labels
    - `plt.close()` after save to free memory
    - PDF for papers, PNG for quick sharing

---

## Matrix Visualization (draw_util.matshow)

```python
from common.draw_util import matshow

matshow(
    matrix,
    max_val=None,      # auto: abs(matrix).max() * 0.1
    colorbar=True,
    frame=True,        # spine border
    ticks=False,       # axis ticks off
    save_name=None,    # saves at 600 dpi
    drawline=[],       # orbital block separators
    ratio=0.8,         # figsize=(6*ratio, 5*ratio)
)
```

**Block separator lines:**

- Positive values in `drawline` → gray dashed (`--`, lw=0.3)
- Negative values in `drawline` → black solid (`-`, lw=0.5)

---

## 3D Molecule (draw_util.view_molecule_3d)

```python
from common.draw_util import view_molecule_3d

view_molecule_3d(
    atoms,              # atomic numbers
    positions,          # coordinates in Angstrom
    style="stick",      # "line", "stick", "sphere", "cartoon"
    surface=False,      # molecular surface
    surface_opacity=0.5,
    size=(600, 400),
)
```

---

## Template: New Figure

```python
import matplotlib.pyplot as plt
import numpy as np

# ---- Style setup ----
FS = {"label": 8, "tick": 7, "annot": 7}
COLORS = {"blue": "#5384EC", "yellow": "#F5B025", "red": "#D85140"}
ratio = 1.05

# ---- Figure ----
fig, ax = plt.subplots(figsize=(2.3 * ratio, 1.45 * ratio))

ax.plot(x, y, "-o", color=COLORS["blue"], linewidth=1.5, markersize=3, zorder=3)

ax.set_xlabel("X Label", fontsize=FS["label"], fontweight="bold")
ax.set_ylabel("Y Label", fontsize=FS["label"], fontweight="bold")
ax.tick_params(direction="out", top=False, right=False, labelsize=FS["tick"])
ax.yaxis.grid(True, which="major", ls=":", alpha=0.9, linewidth=0.6, zorder=0)
ax.xaxis.grid(False)

for spine in ax.spines.values():
    spine.set_linewidth(0.75)

legend = ax.legend(framealpha=1, frameon=True, edgecolor="black", fontsize=FS["annot"])
legend.get_frame().set_linewidth(0.6)

plt.tight_layout()
fig.savefig("output.pdf", dpi=600, bbox_inches="tight", pad_inches=0.02)
plt.close()
```
