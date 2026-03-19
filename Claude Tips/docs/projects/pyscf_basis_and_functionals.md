# PySCF Basis Sets & XC Functionals 가이드

Hamiltonian ML 연구자를 위한 실용 가이드. 각 basis set의 크기, 정확도, 비용과 functional의 특성을 정리합니다.

---

## 1. Basis Set 계층 구조

Basis set은 원자 오비탈을 근사하는 함수의 집합입니다. 함수 수가 많을수록 정확하지만 비용이 증가합니다.

```
Minimal (STO-3G)  →  Double-Zeta (DZ)  →  Triple-Zeta (TZ)  →  Quadruple-Zeta (QZ)  →  CBS
  ~1 func/AO          ~2-3 func/AO         ~4-5 func/AO          ~7-8 func/AO            ∞
```

**DFT에서는 수렴이 빠릅니다**: TZ면 거의 수렴, QZ면 CBS와 차이 무시 가능.
**Correlated methods (CCSD(T))에서는 느림**: QZ 또는 CBS extrapolation 필요.

### 주요 개념

| 기능 | 표기 | 역할 |
|------|------|------|
| **Polarization** | `*`, `(d)`, `(d,p)`, `P` in SVP | 화학 결합 기술 (d on heavy, p on H) |
| **Diffuse** | `+`, `aug-`, `D` in SVPD | 음이온, 여기 상태, 약한 상호작용 |
| **Density Fitting** | `-jkfit`, `-ri` | RI 근사용 보조 basis (4-idx → 3-idx) |

---

## 2. Karlsruhe def2 Family (Hamiltonian ML 표준)

Weigend & Ahlrichs (2005). H-Rn까지 균일하게 정의. **QH9/QHNet/QHFlow의 표준**.

### Basis Functions per Atom (Spherical Harmonics)

| Basis | PySCF 이름 | H | C, N, O, F | 수준 | 상대 비용 |
|-------|-----------|:-:|:----------:|:----:|:---------:|
| def2-SV(P) | `'def2-sv(p)'` | 2 (1s) | 14 (3s2p1d) | DZ (H 무편극) | 1x |
| **def2-SVP** | `'def2-svp'` | **5 (2s1p)** | **14 (3s2p1d)** | **DZ** | **1x** |
| def2-SVPD | `'def2-svpd'` | 9 | 19 | DZ + diffuse | 1.5x |
| def2-TZVP | `'def2-tzvp'` | 11 (3s1p) | 31 (5s3p2d1f) | TZ | 4-6x |
| def2-TZVPP | `'def2-tzvpp'` | 14 (3s2p1d) | 31 (5s3p2d1f) | TZ | 5-7x |
| def2-QZVP | `'def2-qzvp'` | 24 | 55 (7s4p3d2f1g) | QZ | 15-25x |
| def2-QZVPP | `'def2-qzvpp'` | 30 | 55 | QZ | 20-30x |

!!! info "def2-SVP의 orbital 구조 (Hamiltonian ML에서 중요)"
    C, N, O, F: **3s + 2p + 1d = 3×1 + 2×3 + 1×5 = 14 basis functions**
    H: **2s + 1p = 2×1 + 1×3 = 5 basis functions**

    이것이 QHFlow2에서 `MAX_ORBITAL_LENGTH = 14`인 이유입니다.

### Hamiltonian 행렬 크기 비교

전형적인 QM9 분자 (예: C₇H₁₀O₂, 19 atoms):

| Basis | Basis functions | H 행렬 크기 | 원소 수 |
|-------|:--------------:|:----------:|:------:|
| def2-SVP | ~150 | 150 × 150 | 22,500 |
| def2-TZVP | ~450 | 450 × 450 | 202,500 |
| def2-QZVP | ~800 | 800 × 800 | 640,000 |

**def2-SVP → def2-TZVP**: 행렬 크기 **9배**, 계산 비용 **수십 배** 증가.

---

## 3. Dunning cc-pVXZ Family

Dunning (1989). CBS extrapolation에 최적화. Correlated methods (CCSD(T)) 벤치마크용.

| Basis | PySCF 이름 | H | C, N, O | 수준 |
|-------|-----------|:-:|:-------:|:----:|
| cc-pVDZ | `'cc-pvdz'` | 5 | 14 | DZ |
| cc-pVTZ | `'cc-pvtz'` | 14 | 30 | TZ |
| cc-pVQZ | `'cc-pvqz'` | 30 | 55 | QZ |
| cc-pV5Z | `'cc-pv5z'` | 55 | 91 | 5Z |

Augmented (diffuse 추가): `'aug-cc-pvdz'`, `'aug-cc-pvtz'`, ...

!!! note "def2 vs cc-pV_Z 비교"
    DZ 수준에서 def2-SVP와 cc-pVDZ는 **거의 같은 크기** (C: 14 functions).
    TZ에서 def2-TZVP (31)와 cc-pVTZ (30)도 유사.
    DFT에서는 def2가 약간 더 효율적, correlated methods에서는 cc-pVXZ가 적합.

---

## 4. Pople Family (6-31G 계열)

Legacy basis. 유기화학에서 여전히 많이 사용되지만, 새 벤치마크에는 비권장.

| Basis | PySCF 이름 | H | C, N, O | 수준 |
|-------|-----------|:-:|:-------:|:----:|
| STO-3G | `'sto-3g'` | 1 | 5 | Minimal |
| 3-21G | `'3-21g'` | 2 | 9 | Split-valence |
| 6-31G | `'6-31g'` | 2 | 9 | DZ (valence) |
| 6-31G* | `'6-31g*'` | 2 | 15 | DZ + pol. |
| 6-31G** | `'6-31g**'` | 5 | 15 | DZ + pol. (H도) |
| 6-311G** | `'6-311g**'` | 6 | 18 | TZ + pol. |

!!! warning "6-31G 계열의 한계"
    - 주기율표 전체를 균일하게 커버하지 않음
    - 6-311G는 실제로 TZ 품질이 아님 (Jensen 벤치마크)
    - def2 또는 cc-pVXZ 사용 권장

---

## 5. XC Functionals — Jacob's Ladder

아래에서 위로 갈수록 정확하지만 비용 증가.

### Rung 1: LDA (Local Density Approximation)

| Functional | PySCF | 특징 |
|-----------|-------|------|
| SVWN | `'lda,vwn'` | 가장 단순, overbinding ~1 eV, 테스트/솔리드용 |

**정확도**: MAE ~25+ kcal/mol (GMTKN55). **비용**: ~HF와 동일.

### Rung 2: GGA (Generalized Gradient Approximation)

| Functional | PySCF | 특징 |
|-----------|-------|------|
| **PBE** | `'pbe'` | 가장 인기 있는 GGA. 고체 + 일반 화학 |
| BLYP | `'blyp'` | 유기화학에서 인기 |
| BP86 | `'b88,p86'` | 무기/유기금속 |
| revPBE | `'revpbe'` | PBE 개선, 분자용 |

**정확도**: MAE ~8-10 kcal/mol. **비용**: ~HF와 동일.

!!! tip "PBE의 PySCF 표기"
    `'pbe'`, `'pbe,pbe'`, `'PBE'` 모두 동일하게 작동.
    QHFlow2 코드에서 `'pbe, pbe'` (공백 포함)도 사용되는데, PySCF가 이를 올바르게 파싱합니다.

### Rung 3: meta-GGA

| Functional | PySCF | 특징 |
|-----------|-------|------|
| TPSS | `'tpss'` | 비경험적 meta-GGA |
| **SCAN** | `'scan'` | 17개 제약 조건 만족. 다양한 화학에 강함 |
| r²SCAN | `'r2scan'` | SCAN의 수치적 안정화 버전 |
| M06-L | `'m06l'` | 유기금속에 적합 |

**정확도**: MAE ~5-7 kcal/mol. **비용**: ~1.5x GGA.

### Rung 4: Hybrid Functionals

| Functional | PySCF | HF Exchange | 특징 |
|-----------|-------|:-----------:|------|
| **B3LYP** | `'b3lyp'` | 20% | 가장 널리 사용. **QH9/QHFlow 표준** |
| PBE0 | `'pbe0'` | 25% | 비경험적 hybrid |
| M06-2X | `'m062x'` | 54% | 열화학 + 비공유 상호작용 |
| **ωB97X-V** | `'wb97x_v'` | RSH | 상위권 range-separated + VV10 NLC |
| ωB97M-V | `'wb97m_v'` | RSH meta | 최고 수준 범용 functional |
| HSE06 | `'hse06'` | 25% (SR) | 고체용 screened hybrid |
| CAM-B3LYP | `'camb3lyp'` | 19-65% RSH | 전하이동 여기 상태 |

**정확도**: MAE ~3-5 kcal/mol. **비용**: ~3-10x GGA (HF exchange 때문).

!!! warning "B3LYP 단독 사용의 한계"
    B3LYP은 **분산력 (dispersion)을 기술하지 못합니다**.
    D3(BJ) 보정 없는 B3LYP은 비공유 상호작용에서 크게 빗나감.
    B3LYP-D3 > B3LYP (GMTKN55에서 ~2 kcal/mol 차이).
    QH9 데이터셋은 B3LYP without D3로 생성되었음 — 분산력이 중요한 시스템에서 한계.

### Rung 5: Double-Hybrid

| Functional | PySCF | 특징 |
|-----------|-------|------|
| B2PLYP | `'b2plyp'` | HF exchange + MP2 correlation |
| DSD-BLYP-D3 | (custom) | GMTKN55 1위 |

**정확도**: MAE ~1-2 kcal/mol (최고). **비용**: ~50-100x GGA (MP2 필요).

### GMTKN55 벤치마크 순위 (WTMAD-2, kcal/mol)

```
 1. DSD-BLYP-D3(BJ)   ~3.1  ██░░░░░░░░  (double hybrid)
 2. ωB97M-V            ~4.0  ███░░░░░░░  (RSH meta-GGA hybrid)
 3. ωB97X-V            ~4.4  ███░░░░░░░  (RSH hybrid)
 4. PW6B95-D3          ~4.7  ████░░░░░░  (hybrid)
 5. M06-2X             ~5.2  ████░░░░░░  (hybrid)
 6. PBE0-D3            ~6.0  █████░░░░░  (hybrid)
 7. B3LYP-D3           ~6.5  █████░░░░░  (hybrid) ← QH9 functional (without D3)
 8. SCAN               ~7.5  ██████░░░░  (meta-GGA)
 9. PBE                ~9.5  ████████░░  (GGA) ← MD17 ref ham functional
10. LDA               ~25+  ██████████  (LDA)
```

---

## 6. Density Fitting (RI 근사)

4-center 적분을 보조 basis로 분해하여 $O(N^4) \to O(N^3)$ 가속. 오차 ~0.01 kcal/mol.

```python
mf = dft.RKS(mol).density_fit()  # 보조 basis 자동 선택
```

| 주 Basis | 보조 Basis (JK) | 보조 Basis (RI/MP2) |
|---------|:--------------:|:------------------:|
| def2-SVP | `def2-svp-jkfit` | `def2-svp-ri` |
| def2-TZVP | `def2-tzvp-jkfit` | `def2-tzvp-ri` |
| cc-pVDZ | `cc-pvdz-jkfit` | `cc-pvdz-ri` |

!!! note "Hamiltonian ML에서의 DF"
    Density fitting은 **Hamiltonian 행렬의 차원을 바꾸지 않습니다**.
    SCF 수렴 속도만 개선. 하지만 수치적 결과가 미세하게 달라질 수 있으므로
    metadata에 DF 사용 여부를 기록해야 합니다.

---

## 7. Hamiltonian ML 논문에서의 선택

| 논문/데이터셋 | Basis | Functional | 대상 |
|-------------|-------|-----------|------|
| **QH9 / QHNet** | def2-SVP | B3LYP | QM9 (H/C/N/O/F) |
| **QHFlow / QHFlow2** | def2-SVP | B3LYP (QH9) / PBE (MD17) | QM9 / MD17 |
| **SLEM** | def2-SVP | B3LYP | QM9 |
| **DeepH** | NAO (수치 기저) | PBE | 결정 고체 |
| **PhiSNet** | def2-SVP | ωB97X / B3LYP | MD17/QM9 |
| **SchNOrb** | def2-SVP | PBE | ethanol 등 |

**사실상의 표준**: `def2-SVP + B3LYP` (분자), `NAO + PBE` (고체)

---

## 8. 실용 권장 사항

### 데이터 생성용 (기존 문헌 호환)

```python
mol.basis = 'def2-svp'
mf.xc = 'b3lyp'        # QH9 호환
# 또는
mf.xc = 'pbe'           # MD17/SchNOrb 호환
```

### 고정밀 참조 데이터 생성용

```python
mol.basis = 'def2-tzvp'
mf.xc = 'wb97x_v'       # 상위권 RSH, NLC 포함
```

### 프로토타이핑/디버깅용

```python
mol.basis = 'sto-3g'     # 최소 basis, 파이프라인 테스트
mf.xc = 'pbe'            # 빠른 GGA
```

### Basis 선택 의사결정 트리

```
목표가 뭔가?
├── 기존 QH9/QHFlow 벤치마크 재현 → def2-SVP + B3LYP
├── 더 정확한 reference 생성     → def2-TZVP + ωB97X-V
├── 고체/주기계                  → NAO + PBE (+ HSE06)
├── 분산력 중요 (약한 상호작용)   → def2-SVP + B3LYP-D3(BJ)
├── 무거운 원소 (5d 이상)        → def2-TZVP + ECP
└── 코드 테스트                  → STO-3G + PBE
```

---

## 참고 자료

- [PySCF Basis Sets](https://pyscf.org/user/gto.html)
- [PySCF DFT Functionals](https://pyscf.org/user/dft.html)
- [Basis Set Exchange](https://www.basissetexchange.org/)
- [Weigend & Ahlrichs, def2 basis sets (PCCP, 2005)](https://doi.org/10.1039/b508541a)
- [Goerigk et al., GMTKN55 benchmark (PCCP, 2017)](https://doi.org/10.1039/C7CP04913G)
- [QH9 dataset paper (NeurIPS, 2023)](https://arxiv.org/abs/2306.09549)
