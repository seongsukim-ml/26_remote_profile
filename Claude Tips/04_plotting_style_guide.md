# 논문/발표용 Plot 스타일 가이드

## 폰트 설정

### 설치된 폰트

| Preset key | Font | 용도 |
|---|---|---|
| `liberation` | Liberation Sans | Arial 호환, 논문 기본값 |
| `din2014` | DIN 2014 | 기하학적 sans, 현대적 |
| `din2014-narrow` | DIN 2014 Narrow | 좁은 공간용 |
| `dmsans` | DM Sans | DIN-inspired, 무료 (Google Fonts) |
| `bebas` | Bebas Neue | 대문자 전용, 타이틀 강조 |

폰트 파일 위치: `/home1/irteam/data-vol1/fonts/`

### matplotlib에서 사용

```python
import matplotlib.pyplot as plt
import matplotlib.font_manager as fm
from pathlib import Path

# 폰트 등록 (컨테이너 재시작 시 필요)
FONT_DIR = Path("/home1/irteam/data-vol1/fonts")
mpl_ttf = Path(fm.findfont("DejaVu Sans")).parent
import shutil
for ext in ("*.ttf", "*.otf"):
    for src in list(FONT_DIR.glob(ext)) + list(FONT_DIR.glob(f"*/{ext}")):
        dst = mpl_ttf / src.name
        if not dst.exists():
            shutil.copy2(src, dst)

import matplotlib
for f in Path(matplotlib.get_cachedir()).glob("fontlist-*.json"):
    f.unlink()
fm._load_fontmanager(try_read_cache=False)
for f in mpl_ttf.glob("*.otf"):
    fm.fontManager.addfont(str(f))

# rcParams 설정
plt.rcParams.update({
    "font.sans-serif": ["DIN 2014", "Liberation Sans", "DejaVu Sans"],
    "font.family": "sans-serif",
    "axes.unicode_minus": False,
    "pdf.fonttype": 42,   # TrueType embed (Illustrator 편집 가능)
    "ps.fonttype": 42,
})
```

새 폰트 추가: `.ttf`/`.otf` 파일을 `/home1/irteam/data-vol1/fonts/`에 넣으면 자동 등록.

---

## 스타일 규칙

### 공통 규칙

| 항목 | 규칙 |
|---|---|
| Box (spine) | 4면 닫힘 |
| Ticks | bottom + left만 (top/right 없음) |
| Tick direction | outward |
| Grid | y축만, 점선 (`:`, alpha=0.5) |
| Unit 표기 | `quantity / unit` (IUPAC 권장) |
| Legend | 반투명 배경, 연한 회색 테두리 |
| 주인공 선 | 실선, 굵게, alpha=0.9 |
| 비교 대상 | 점선/파선, 얇게, alpha=0.45 |
| PDF | fonttype 42 (TrueType) |
| Label bold | 축 라벨 bold 아님, legend에서 주인공만 bold |

### 사이즈 프리셋

| Preset | 용도 | 폭 | 폰트 기준 |
|---|---|---|---|
| `compact` | 논문 single-column | ~3.3 in | 6–7 pt |
| `normal` | 발표/double-column | ~7 in | 9–11 pt |

### Unit 표기 예시

| Bad | Good |
|---|---|
| `Energy (eV)` | `Energy / eV` |
| `Parameters (M)` | `Parameters / M` |
| `r(O-H) [Å]` | `$r_{\mathrm{O-H}}$ / Å` |

---

## 컬러 테마

### 범용 테마

| Theme | 용도 | m1 (ours) | m2 | m3 | m4 |
|---|---|---|---|---|---|
| `warm` | 논문 기본 | `#E87A6B` | `#B0A9E6` | `#A5CF9F` | `#C0C0C0` |
| `cool` | 슬라이드 | `#3B82F6` | `#F97316` | `#10B981` | `#A1A1AA` |
| `earth` | Nature/Science | `#C44E52` | `#4C72B0` | `#55A868` | `#8C8C8C` |
| `mono` | 흑백 인쇄 | `#1a1a1a` | `#666666` | `#999999` | `#cccccc` |
| `accessible` | 색맹 안전 | `#E69F00` | `#56B4E9` | `#009E73` | `#CC79A7` |

### QHFlow2 프로젝트 테마

| Theme | 출처 | m1 | m2 | m3 | m4 |
|---|---|---|---|---|---|
| `qh-coral` | param_vs_perf | `#D85140` | `#5384EC` | `#F5B025` | `#7BA3F0` |
| `qh-scaling` | md17_datascaling | `#E87A6B` | `#B0A9E6` | `#A5CF9F` | `#C0C0C0` |
| `qh-scf` | scf_acceleration | `#8C6CE7` | `#C45C1C` | `#5DA7E2` | `#6F6F6F` |
| `qh-tropical` | pred_time_scale | `#FF6B6B` | `#4ECDC4` | `#45B7D1` | `#98D8C8` |
| `qh-vega` | malon_draw | `#E45756` | `#4C78A8` | `#54A24B` | `#333333` |

---

## 샘플 코드

### 빠른 시작 (복붙용)

```python
import matplotlib
matplotlib.use("Agg")
import matplotlib.pyplot as plt
import numpy as np
import seaborn as sns

# ── 스타일 헬퍼 ──────────────────────────────────────────────────
def style_ax(ax, grid_y=True, spine_lw=0.5, tick_size=6):
    """Ticks on bottom+left, box closed, y-grid only."""
    ax.tick_params(direction="out", top=False, right=False, labelsize=tick_size)
    ax.tick_params(which="major", length=2.0)
    ax.tick_params(which="minor", length=1.0)
    if grid_y:
        ax.yaxis.grid(True, which="major", ls=":", alpha=0.5, lw=0.4, zorder=0)
        ax.xaxis.grid(False)
        ax.grid(False, which="minor")
    for sp in ax.spines.values():
        sp.set_linewidth(spine_lw)


def bold_legend(ax, bold_name="QHFlow2", fontsize=5.5):
    """Legend with soft frame, bold for our model."""
    leg = ax.legend(framealpha=0.95, frameon=True, edgecolor="#cccccc",
                    fontsize=fontsize, handlelength=1.5,
                    borderpad=0.3, labelspacing=0.3)
    leg.get_frame().set_linewidth(0.4)
    for t in leg.get_texts():
        if bold_name in t.get_text():
            t.set_fontweight("bold")


def save(fig, name, dpi=300):
    """Save png + pdf."""
    fig.savefig(f"{name}.png", dpi=dpi, bbox_inches="tight", facecolor="white")
    fig.savefig(f"{name}.pdf", dpi=600, bbox_inches="tight", pad_inches=0.02)
    plt.close(fig)
```

### 테마 적용 예시

```python
# 테마 선택
T = {
    "m1": "#D85140", "m2": "#5384EC", "m3": "#F5B025", "m4": "#7BA3F0",
    "bar": ["#757575", "#D85140", "#5384EC"],
    "dft": "#D55E00", "ml": "#5384EC",
    "cmap": "YlOrRd",
}

# Line plot
fig, ax = plt.subplots(figsize=(2.5, 1.7))
ax.plot(x, y_ours, "-o", color=T["m1"], lw=1.2, ms=2.5, alpha=0.9, label="Ours")
ax.plot(x, y_base, "--o", color=T["m2"], lw=0.8, ms=2.5, alpha=0.45, label="Baseline")
ax.set_xlabel("Parameters / M", fontsize=7)
ax.set_ylabel("MAE / meV", fontsize=7)
style_ax(ax)
bold_legend(ax, bold_name="Ours")
plt.tight_layout()
save(fig, "my_plot")

# Heatmap
fig, ax = plt.subplots(figsize=(3.5, 2.0))
sns.heatmap(df, annot=True, fmt=".1f", cmap=T["cmap"],
            linewidths=0.5, linecolor="white", ax=ax)

# Violin
fig, ax = plt.subplots(figsize=(3.0, 1.8))
sns.violinplot(data=df, x="Model", y="|Error| / meV", hue="Model",
               palette=[T["m1"], T["m2"], T["m3"], T["m4"]],
               inner="quart", linewidth=0.6, cut=0, legend=False)
```

---

## 샘플 생성 도구

```bash
cd /home1/irteam/data-vol1/temp

# 전체 옵션 보기
python style_sample.py --help
python style_sample.py --list-fonts
python style_sample.py --list-themes

# 샘플 생성
python style_sample.py --font din2014 --size compact --theme qh-coral
python style_sample.py --font din2014 --size normal  --theme warm

# 테마 갤러리 생성
python theme_gallery.py
```

출력 위치: `/home1/irteam/data-vol1/temp/samples/{font}/{size}/{theme}/`

갤러리: `/home1/irteam/data-vol1/temp/samples/theme_gallery.pdf`
