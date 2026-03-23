# 논문/발표용 Plot 스타일 가이드

> **이 파일은 요약본입니다.** 전체 문서: `docs/python/plot_style_guide.md`
>
> Plot 헬퍼 패키지: `labutils.plotting`
> 소스: `/home1/irteam/data-vol1/projects/utils/src/labutils/plotting/`

## 설치

```bash
pip install -e /home1/irteam/data-vol1/projects/utils
```

## 사용법

```python
from labutils.plotting import setup_fonts, style_ax, bold_legend, save, THEMES, SIZES

setup_fonts()                          # DIN 2014 등록 (세션당 1회)
T, S = THEMES["warm"], SIZES["compact"]

fig, ax = plt.subplots(figsize=S["figsize"])
ax.plot(x, y, "-o", color=T["m1"], lw=S["lw_main"], ms=S["ms"], alpha=0.9, label="Ours")
ax.set_xlabel("Energy / eV", fontsize=S["label"])
style_ax(ax, tick_size=S["tick"], spine_lw=S["spine_lw"])
bold_legend(ax, bold_name="Ours", fontsize=S["legend"])
plt.tight_layout()
save(fig, "my_plot")
```

## API

| Function | 역할 |
|---|---|
| `setup_fonts()` | DIN 2014 폰트 등록 + rcParams 설정 |
| `style_ax(ax)` | Closed box, bottom+left tick, y-grid |
| `bold_legend(ax, bold_name)` | Soft frame legend, 주인공만 bold |
| `save(fig, name)` | PNG 300dpi + PDF 600dpi 동시 저장 |
| `THEMES` | 컬러 테마 dict (warm, cool, earth, mono, accessible, qh-*) |
| `SIZES` | 사이즈 프리셋 (compact, normal) |

## 스타일 규칙

| 항목 | 규칙 |
|---|---|
| Box (spine) | 4면 닫힘 |
| Ticks | bottom + left만, outward |
| Grid | y축만, 점선, alpha=0.5 |
| Unit 표기 | `quantity / unit` (IUPAC) |
| Legend | #cccccc edge, framealpha=0.95 |
| Axis label | bold 아님 |
| PDF | fonttype 42 |

## 테마

| Theme | 용도 | m1 (ours) | m2 | m3 | m4 |
|---|---|---|---|---|---|
| `warm` | 논문 기본 | `#E87A6B` | `#B0A9E6` | `#A5CF9F` | `#C0C0C0` |
| `cool` | 슬라이드 | `#3B82F6` | `#F97316` | `#10B981` | `#A1A1AA` |
| `earth` | Nature/Science | `#C44E52` | `#4C72B0` | `#55A868` | `#8C8C8C` |
| `mono` | 흑백 인쇄 | `#1a1a1a` | `#666666` | `#999999` | `#cccccc` |
| `accessible` | 색맹 안전 | `#E69F00` | `#56B4E9` | `#009E73` | `#CC79A7` |
