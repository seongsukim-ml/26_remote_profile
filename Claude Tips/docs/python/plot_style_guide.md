# Plot Style Guide

논문/발표용 시각화 컨벤션. `labutils.plotting` 패키지로 구현되어 있다.

!!! tip "핵심 원칙"
    Plot을 그릴 때는 **반드시** `labutils.plotting`을 사용한다.
    직접 style 코드를 복붙하지 않는다.

---

## 설치

`labutils`는 editable install로 관리. 각 conda env에서 한 번만 실행:

```bash
pip install -e /home1/irteam/data-vol1/projects/utils
```

소스 위치: `/home1/irteam/data-vol1/projects/utils/src/labutils/`

---

## 빠른 시작

```python
import matplotlib
matplotlib.use("Agg")
import matplotlib.pyplot as plt
import numpy as np
from labutils.plotting import setup_fonts, style_ax, bold_legend, save, THEMES, SIZES

setup_fonts()  # DIN 2014 등록 (세션당 1회)

T = THEMES["warm"]
S = SIZES["compact"]

fig, ax = plt.subplots(figsize=S["figsize"])
ax.plot(x, y_ours, "-o", color=T["m1"], lw=S["lw_main"], ms=S["ms"],
        alpha=0.9, label="Ours")
ax.plot(x, y_base, "--o", color=T["m2"], lw=S["lw_base"], ms=S["ms"],
        alpha=0.45, label="Baseline")
ax.set_xlabel("Parameters / M", fontsize=S["label"])
ax.set_ylabel("MAE / meV", fontsize=S["label"])
style_ax(ax, tick_size=S["tick"], spine_lw=S["spine_lw"])
bold_legend(ax, bold_name="Ours", fontsize=S["legend"])
plt.tight_layout()
save(fig, "my_plot")  # → my_plot.png (300dpi) + my_plot.pdf (600dpi)
```

---

## API Reference

### `setup_fonts(font_dir=FONT_DIR)`

DIN 2014 폰트를 matplotlib에 등록하고 rcParams를 설정한다.

- Font stack: DIN 2014 → Liberation Sans → DejaVu Sans
- `pdf.fonttype = 42` (TrueType, Illustrator 편집 가능)
- 폰트 파일 위치: `/home1/irteam/data-vol1/fonts/`
- 세션당 1회 호출. 이미 복사된 폰트는 건너뛴다.

### `style_ax(ax, *, grid_y=True, spine_lw=0.5, tick_size=6)`

스타일 가이드에 맞게 축을 포맷한다.

- **Box**: 4면 닫힘 (spine 모두 visible)
- **Ticks**: bottom + left만, direction=out
- **Grid**: y축만, 점선 (`:`, alpha=0.5, lw=0.4)

### `bold_legend(ax, bold_name="", fontsize=5.5, **kwargs)`

소프트 프레임 legend를 추가한다.

- Frame: `edgecolor="#cccccc"`, `framealpha=0.95`, `linewidth=0.4`
- `bold_name`에 해당하는 항목만 bold 처리
- `**kwargs`는 `ax.legend()`에 전달

### `save(fig, name, *, dpi=300, pdf_dpi=600, close=True)`

PNG + PDF 동시 저장.

- PNG: `dpi=300`, `facecolor="white"`, `bbox_inches="tight"`
- PDF: `dpi=600`, `pad_inches=0.02`
- `close=True`이면 저장 후 `plt.close(fig)`

### `SIZES`

사이즈 프리셋 dict. 키마다 `figsize`, `label`, `tick`, `legend`, `title`, `annot`, `lw_main`, `lw_base`, `ms`, `spine_lw` 포함.

| Preset | 용도 | figsize | 폰트 기준 |
|---|---|---|---|
| `compact` | 논문 single-column | (2.5, 1.7) | 6–7 pt |
| `normal` | 발표/double-column | (7, 3.5) | 9–11 pt |

### `THEMES`

컬러 테마 dict. 각 테마에 `m1`–`m4`, `bar`, `dft`, `ml`, `cmap` 포함.

| Theme | 용도 | m1 (ours) | m2 | m3 | m4 |
|---|---|---|---|---|---|
| `warm` | 논문 기본 | `#E87A6B` | `#B0A9E6` | `#A5CF9F` | `#C0C0C0` |
| `cool` | 슬라이드 | `#3B82F6` | `#F97316` | `#10B981` | `#A1A1AA` |
| `earth` | Nature/Science | `#C44E52` | `#4C72B0` | `#55A868` | `#8C8C8C` |
| `mono` | 흑백 인쇄 | `#1a1a1a` | `#666666` | `#999999` | `#cccccc` |
| `accessible` | 색맹 안전 | `#E69F00` | `#56B4E9` | `#009E73` | `#CC79A7` |
| `qh-coral` | QHFlow2 param_vs_perf | `#D85140` | `#5384EC` | `#F5B025` | `#7BA3F0` |
| `qh-scaling` | QHFlow2 datascaling | `#E87A6B` | `#B0A9E6` | `#A5CF9F` | `#C0C0C0` |
| `qh-scf` | QHFlow2 scf | `#8C6CE7` | `#C45C1C` | `#5DA7E2` | `#6F6F6F` |
| `qh-tropical` | QHFlow2 pred_time | `#FF6B6B` | `#4ECDC4` | `#45B7D1` | `#98D8C8` |
| `qh-vega` | QHFlow2 malon_draw | `#E45756` | `#4C78A8` | `#54A24B` | `#333333` |

---

## 스타일 규칙 요약

| 항목 | 규칙 |
|---|---|
| Box (spine) | 4면 닫힘 |
| Ticks | bottom + left만 (top/right 없음), outward |
| Grid | y축만, 점선 (`:`, alpha=0.5) |
| Unit 표기 | `quantity / unit` (IUPAC): `Energy / eV`, `Parameters / M` |
| Legend | 반투명 배경 (#cccccc edge), 주인공만 bold |
| 주인공 선 | 실선, 굵게 (`lw_main`), alpha=0.9 |
| 비교 대상 | 점선/파선, 얇게 (`lw_base`), alpha=0.45 |
| Axis label | **bold 아님** |
| PDF | fonttype 42 (TrueType) |

### Unit 표기 예시

| Bad | Good |
|---|---|
| `Energy (eV)` | `Energy / eV` |
| `Parameters (M)` | `Parameters / M` |
| `r(O-H) [Å]` | `$r_{\mathrm{O-H}}$ / Å` |

### Line Style Convention

| Series | Style | lw | alpha |
|---|---|---|---|
| Ours | `-` (solid) | `S["lw_main"]` | 0.9 |
| Baseline 1 | `--` (dashed) | `S["lw_base"]` | 0.45 |
| Baseline 2 | `-.` (dash-dot) | `S["lw_base"]` | 0.45 |
| Baseline 3 | `:` (dotted) | `S["lw_base"]` | 0.45 |

---

## 용례별 예시

### Line Plot (모델 비교)

```python
from labutils.plotting import setup_fonts, style_ax, bold_legend, save, THEMES, SIZES
setup_fonts()
T, S = THEMES["warm"], SIZES["compact"]

fig, ax = plt.subplots(figsize=S["figsize"])
ax.plot(x, y1, "-o",  color=T["m1"], lw=S["lw_main"], ms=S["ms"], alpha=0.9, label="Ours")
ax.plot(x, y2, "--s", color=T["m2"], lw=S["lw_base"], ms=S["ms"], alpha=0.45, label="Baseline")
ax.set_xlabel("Parameters / M", fontsize=S["label"])
ax.set_ylabel("MAE / meV", fontsize=S["label"])
style_ax(ax, tick_size=S["tick"], spine_lw=S["spine_lw"])
bold_legend(ax, bold_name="Ours", fontsize=S["legend"])
plt.tight_layout()
save(fig, "line_plot")
```

### Bar Chart

```python
T, S = THEMES["warm"], SIZES["normal"]

fig, ax = plt.subplots(figsize=(4, 2.5))
bars = ax.bar(labels, values, color=T["bar"])
ax.bar_label(bars, padding=1, fmt="%.1f", fontsize=S["annot"])
ax.set_ylabel("SCF Cycles", fontsize=S["label"])
style_ax(ax, tick_size=S["tick"])
plt.tight_layout()
save(fig, "bar_chart")
```

### Heatmap (seaborn)

```python
import seaborn as sns
T = THEMES["warm"]

fig, ax = plt.subplots(figsize=(3.5, 2.0))
sns.heatmap(df, annot=True, fmt=".1f", cmap=T["cmap"],
            linewidths=0.5, linecolor="white", ax=ax)
style_ax(ax, grid_y=False)
save(fig, "heatmap")
```

### Violin (seaborn)

```python
T = THEMES["warm"]
palette = [T["m1"], T["m2"], T["m3"], T["m4"]]

fig, ax = plt.subplots(figsize=(3.0, 1.8))
sns.violinplot(data=df, x="Model", y="|Error| / meV", hue="Model",
               palette=palette, inner="quart", linewidth=0.6, cut=0, legend=False)
style_ax(ax)
save(fig, "violin")
```

---

## 샘플 출력

샘플 생성 스크립트: `/tmp/style_sample.py`

```bash
python /tmp/style_sample.py
# → /tmp/style_sample_{1,2,3}.{png,pdf}
```

Figure 1 (line), Figure 2 (bar), Figure 3 (dissociation curve) 세 가지 유형.
