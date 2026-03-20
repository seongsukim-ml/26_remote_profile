# Equivariant Irrep Decomposition of Hamiltonian Matrix Blocks

## 1. 동기

DFT Hamiltonian 행렬의 orbital 블록 $H^{l_1, l_2} \in \mathbb{R}^{(2l_1+1) \times (2l_2+1)}$은 단순한 feature vector가 아니라, 양쪽에서 Wigner-D로 변환되는 **tensor product representation**입니다:

$$H' = D^{l_1}(R) \, H \, D^{l_2}(R)^T$$

이 구조를 irreducible representation (irrep) 계수로 분해하고 복원하는 알고리즘을 구현하고, 이 과정이 rotation equivariant함을 수치적으로 증명했습니다.

### 왜 필요한가

1. **Equivariant normalization**: per-irrep 통계($\mu$, $\sigma$)로 normalize하면 equivariance 보존
2. **불균형 해소**: s-s 블록(~20 Ha)과 d-d 블록(~0.01 Ha)의 magnitude 차이를 irrep 단위로 처리
3. **Flow matching**: prior와 target의 scale을 irrep별로 맞추면 flow path가 균일
4. **Physical interpretability**: 각 irrep $L$ 성분이 특정 물리적 의미를 가짐 (L=0: isotropic, L=2: quadrupolar 등)

---

## 2. 수학적 배경

### 2.1 Tensor Product Decomposition

$(2l_1+1) \times (2l_2+1)$ 행렬은 $l_1 \otimes l_2$ tensor product 공간에 살고 있으며, Clebsch-Gordan (CG) 분해에 의해 irrep들로 분해됩니다:

$$l_1 \otimes l_2 = \bigoplus_{L=|l_1-l_2|}^{l_1+l_2} L$$

CG 행렬 $C$는 이 분해를 실현하는 orthogonal change-of-basis 행렬입니다:

$$C^T (D^{l_1} \otimes D^{l_2}) C = \bigoplus_L D^L$$

### 2.2 Flatten과 Reconstruct

- **Flatten**: $\vec{h} = C^T \text{vec}(H)$, 여기서 $\vec{h}$를 $L$별로 분할하면 $\{h^L \in \mathbb{R}^{2L+1}\}$
- **Reconstruct**: $\text{vec}(H) = C \vec{h}$

### 2.3 Equivariance

행렬 공간에서의 회전 $H' = D^{l_1} H D^{l_2,T}$는 irrep 공간에서 **각 irrep의 독립적인 회전**에 대응합니다:

$$h'^L = D^L(R) \, h^L$$

이것이 equivariance입니다: flatten과 rotation이 교환(commute)합니다.

### 2.4 Normalization이 Equivariant한 이유

$\|h^L\|$은 rotation invariant ($\|D^L h^L\| = \|h^L\|$, $D^L$이 orthogonal이므로).
따라서:

| 연산 | L=0 (scalar) | L>0 (non-scalar) | Equivariant? |
|:----:|:---:|:---:|:---:|
| $h^L / \sigma$ (invariant scalar로 나누기) | O | O | **보존** |
| $h^L - \mu$ (shift) | O | **X** | L=0만 가능 |
| $h^L - \mu \cdot \delta_{L,0}$ (L=0에만 shift) | O | — | **보존** |

---

## 3. 알고리즘 구현

### 3.1 CG 행렬 계산 (Casimir Method)

독립적으로 $D^L$을 계산하면 basis mismatch 문제가 발생합니다. 이를 방지하기 위해 $D^L$을 CG 행렬로부터 **추출**합니다.

**방법**:

1. Real spherical harmonic basis에서 angular momentum generator $G_x, G_y, G_z$ 구성
2. Product basis에서 total Casimir $G^2 = G_x^2 + G_y^2 + G_z^2$ 계산
3. $-G^2$의 eigenvalues = $L(L+1)$ → 각 $L$의 부분공간 식별
4. Eigenvectors를 $L$별로 묶으면 CG 행렬 $C$의 columns

**핵심**: $D^L$은 $C_L^T (D^{l_1} \otimes D^{l_2}) C_L$로 추출. 독립 계산 없이 basis consistency 보장.

### 3.2 코드

```python
from common.irrep_decompose import IrrepDecomposer

# d-d 블록 (l1=2, l2=2)
dec = IrrepDecomposer(l1=2, l2=2)
# → (5×5) → L=0 (1) + L=1 (3) + L=2 (5) + L=3 (7) + L=4 (9) = 25 components

# Flatten: 행렬 → irrep 계수
coeffs = dec.flatten(H)   # {0: (1,), 1: (3,), 2: (5,), 3: (7,), 4: (9,)}

# Reconstruct: irrep 계수 → 행렬
H_rec = dec.reconstruct(coeffs)   # (5, 5), 완벽 복원

# Batched
coeffs_batch = dec.flatten_batch(H_batch)      # {L: (B, 2L+1)}
H_batch_rec = dec.reconstruct_batch(coeffs_batch)

# Irrep 공간에서 회전
coeffs_rot = dec.rotate_irreps(coeffs, R)

# Irrep norms (rotation invariant)
norms = dec.irrep_norms(coeffs)   # {L: scalar}
```

### 3.3 지원 범위

| l | Orbital | 테스트 |
|:-:|---------|:------:|
| 0 | s | PASS |
| 1 | p | PASS |
| 2 | d | PASS |
| 3 | f | PASS |
| 4 | g | PASS |

모든 $(l_1, l_2)$ 조합 15쌍 검증 완료.

---

## 4. 실험 결과

### 4.1 Roundtrip (완전성)

$$\text{reconstruct}(\text{flatten}(H)) = H$$

| (l1, l2) | Max Error |
|:--------:|:---------:|
| (0,0) s-s | 0.0e+00 |
| (0,1) s-p | 0.0e+00 |
| (1,1) p-p | 1.6e-15 |
| (1,2) p-d | 2.0e-15 |
| (2,2) d-d | 3.1e-15 |
| (2,3) d-f | 3.0e-15 |
| (3,3) f-f | 3.1e-15 |
| (3,4) f-g | 3.6e-15 |
| (4,4) g-g | 3.9e-15 |

### 4.2 Norm Preservation (Parseval)

$$\|H\|_F^2 = \sum_L \|h^L\|^2$$

모든 pair에서 ~1e-14 이하 오차. CG 행렬이 orthogonal이므로 수학적으로 정확.

### 4.3 Rotation Equivariance (핵심 결과)

$$\text{flatten}(D^{l_1} H D^{l_2,T}) = D^L \cdot \text{flatten}(H) \quad \forall L$$

| (l1, l2) | Max Error | Rotations |
|:--------:|:---------:|:---------:|
| (0,0) s-s | 0.0e+00 | 20 |
| (0,1) s-p | 0.0e+00 | 20 |
| (1,1) p-p | 2.2e-15 | 20 |
| (1,2) p-d | 2.7e-15 | 20 |
| (2,2) d-d | 8.4e-15 | 20 |
| (2,3) d-f | 6.4e-15 | 20 |
| (3,3) f-f | 1.2e-14 | 20 |
| (3,4) f-g | 1.5e-14 | 20 |
| (4,4) g-g | 1.9e-14 | 20 |

모든 오차가 machine precision (~1e-14) 이내. **Equivariance 수치적으로 증명됨.**

### 4.4 Irrep Norm Invariance

$$\|h^L(R \cdot H)\| = \|h^L(H)\| \quad \forall R \in SO(3)$$

20개 랜덤 회전에서 모든 $(l_1, l_2, L)$에 대해 ~1e-14 이내 일치. Per-irrep normalization의 근거.

### 4.5 Negative Control

CG가 아닌 랜덤 orthogonal basis로 per-component scaling → **equivariance 깨짐** (error ~1.0). CG 분해가 유일하게 올바른 방법임을 확인.

### 4.6 p-d Block 예시 (구체적 수치)

$l_1=1, l_2=2$ (p-d block, 3×5 → L=1,2,3):

```
Path A: H → flatten → {h^L} → D^L · h^L    (irrep에서 회전)
Path B: H → D^1 H D^{2,T} → flatten → {h'^L}  (행렬에서 회전 후 분해)

L=1 (dim=3):
  Path A: [0.16989302, 0.91704596, 0.61645356]
  Path B: [0.16989302, 0.91704596, 0.61645356]
  max |A-B| = 3.00e-15  ✓

L=2 (dim=5):
  Path A: [0.35274557, -0.81913231, 0.45726456, ...]
  Path B: [0.35274557, -0.81913231, 0.45726456, ...]
  max |A-B| = 1.33e-15  ✓

L=3 (dim=7):
  Path A: [1.35179661, -0.05732191, 0.50147159, ...]
  Path B: [1.35179661, -0.05732191, 0.50147159, ...]
  max |A-B| = 1.33e-15  ✓

Irrep norms (before/after rotation):
  L=1: 1.117968 / 1.117968  (diff=6.66e-16)  ✓
  L=2: 1.650026 / 1.650026  (diff=0.00e+00)  ✓
  L=3: 1.742066 / 1.742066  (diff=2.22e-16)  ✓
```

---

## 5. Equivariant Normalization에의 적용

### 5.1 SLEM-style Per-Irrep Normalization

Training set에서 $(Z_i, Z_j, l_1, l_2, L)$ 단위로 통계를 계산:

```python
# Training set에서 per-(l1, l2, L) 통계 수집
for H_block in training_blocks:
    coeffs = dec.flatten(H_block)
    for L, h_L in coeffs.items():
        stats[L]["norms"].append(h_L.norm().item())

# σ_L = RMS of norms
for L in stats:
    sigma_L = torch.tensor(stats[L]["norms"]).pow(2).mean().sqrt()

# Normalize
def normalize(coeffs, stats):
    return {
        L: (h - stats[L].mu) / stats[L].sigma if L == 0
           else h / stats[L].sigma
        for L, h in coeffs.items()
    }
```

### 5.2 왜 Equivariant한가

1. $\sigma_L$은 $\|h^L\|$의 RMS → rotation invariant → invariant scalar로 나누기 → equivariant
2. $\mu$는 L=0 (scalar)에만 적용 → L=0는 rotation에 불변 → shift 안전
3. L>0에는 shift 없음 → preferred direction 도입하지 않음

### 5.3 기대 효과

| 측면 | 현재 (raw MSE) | Per-irrep normalization 후 |
|------|---------------|--------------------------|
| Gradient balance | s-s가 지배 | 모든 블록 ~O(1) |
| Flow matching | prior-target scale 불일치 | 균일한 flow path |
| 학습 안정성 | lr 선택 어려움 | 등방적 loss landscape |

---

## 6. Complexity 분석

### 6.1 이론적 복잡도

Flatten/reconstruct는 각각 matrix-vector multiply $C^T \cdot \text{vec}(H)$ 한 번:

$$O\big((2l_1+1)^2 \cdot (2l_2+1)^2\big)$$

| (l1, l2) | Block 크기 | vec 차원 | FLOPs |
|:---------:|:---------:|:-------:|------:|
| (1,1) p-p | 3×3 | 9 | 162 |
| (2,2) d-d | 5×5 | 25 | 1,250 |
| (3,3) f-f | 7×7 | 49 | 4,802 |
| (4,4) g-g | 9×9 | 81 | 13,122 |

Neural network forward (~수백만 FLOPs) 대비 무시할 수 있는 수준.

### 6.2 실측 (CPU, Batch=256)

| (l1, l2) | flatten+reconstruct | element MAE | 배율 |
|:---------:|:------------------:|:-----------:|:----:|
| (1,1) p-p | 31 μs | 9 μs | 3.4x |
| (2,2) d-d | 461 μs | 12 μs | 38x |
| (3,3) f-f | 1,688 μs | 37 μs | 46x |

d-d 이상에서 배치 처리 시 overhead가 커지지만, def2-SVP (최대 d-orbital)에서는 training step 총 시간의 **< 0.5%**. **Loss에서만 사용하고 model 내부에는 넣지 않는 것**이 적절.

---

## 7. Matrix Output Loss: Vision과의 대응

### 7.1 Element-wise MAE/MSE의 한계

Vision에서 pixel-wise MSE가 blurry한 결과를 내는 것과 동일하게, Hamiltonian element-wise MAE는 **큰 블록(s-s)이 gradient를 지배**하고, 작은 블록(d-d)의 anisotropy가 학습되지 않는 문제가 있음.

### 7.2 Vision → Hamiltonian 번역

| Vision | Hamiltonian |
|--------|------------|
| Pixel MSE | Element-wise MAE/MSE (현재) |
| Perceptual Loss (VGG feat) | WALoss (eigenspace projection) |
| **FFT Frequency Loss** | **Irrep-weighted Loss (CG decompose)** |
| Multi-scale Pyramid | Block-wise hierarchical Loss |
| SSIM | Spectral similarity |
| Min-SNR weighting | Time-dependent flow weight |

### 7.3 Irrep-weighted Loss (제안)

Vision에서 FFT frequency decomposition → per-frequency weighting이 큰 개선을 줬듯이, Hamiltonian에서 CG decomposition → per-irrep weighting도 같은 효과를 기대:

| | 저주파 (smooth) | 고주파 (edge/texture) |
|--|----------------|---------------------|
| **Vision (FFT)** | DC component | High-freq details |
| **Hamiltonian (CG)** | L=0 (isotropic, on-site) | L>0 (anisotropy, crystal field) |
| **Problem** | MSE에서 고주파 무시됨 | MAE에서 L>0 무시됨 |
| **Solution** | Per-freq weighting | Per-irrep weighting |

```python
# Irrep-weighted loss
loss = 0
for L, (h_pred, h_target) in irrep_pairs.items():
    loss += weight[L] * (h_pred - h_target).pow(2).mean()
```

---

## 8. MoE-style MultiHeadExpansion

### 8.1 동기

QHFlow2의 현재 Expansion layer는 **모든 원소에 동일한 output_irrep** (def2-SVP: "3x0e + 2x1e + 1x2e", 14-dim)을 사용. 원소마다 실제 orbital 구조가 다르므로:

| 원소 | 실제 orbital | output dim | 14×14에서 낭비 |
|------|-------------|:----------:|:-------------:|
| H (sp) | 2x0e + 1x1e | 5 | 87% |
| C (spd) | 3x0e + 2x1e + 1x2e | 14 | 0% |
| Fe (spdf) | 4x0e + 3x1e + 2x2e + 1x3e | 30 | **불가능** |

spdf 원소(transition metal)를 지원하려면 output을 30-dim으로 키워야 하고, 그러면 H의 낭비가 더 커짐.

### 8.2 설계

```
모든 atom → 공유 backbone (message passing)
         → 원소군별 output head (routing by Z, deterministic)
            sp   head → 5×5    block
            spd  head → 14×14  block
            spdf head → 30×30  block
```

- **Routing은 deterministic** (원자 번호 → 그룹 매핑 테이블)
- Backbone (GNN)은 공유, **Expansion만 분리**
- Off-diagonal (ij) block: group pair별 Expansion → 3 groups면 6 pair combinations

### 8.3 검증 결과

모든 테스트 통과:

| Test | 결과 |
|------|:----:|
| Output shape (5×5, 14×14, 30×30) | ✓ |
| **Equivariance** (모든 그룹 ~1e-16) | ✓ |
| Cross-group pair blocks (8종 조합) | ✓ |
| Gradient flow | ✓ |
| Single head와 bit-identical (spd 그룹) | ✓ |

### 8.4 Throughput (H200 GPU)

**Naive 구현** (boolean mask + 별도 forward):

| Scenario | N | Single | Naive Multi | Fast/Single |
|----------|:-:|:------:|:-----------:|:-----------:|
| Pure organic (HCNO) | 38 | 10.0ms | 18.9ms | 0.53x |
| TM complex | 31 | 11.0ms | 35.0ms | 0.31x |

→ **느림.** 원인: group별 routing overhead + small-batch GPU 비활용.

**최적화 (FastExpansion: w3j 캐싱 + pre-sort)**:

| Scenario | N | Single | Fast Multi | Fast/Single |
|----------|:-:|:------:|:----------:|:-----------:|
| Pure organic (HCNO) | 38 | 10.0ms | **9.6ms** | **0.97x** |
| Small organic (EtOH) | 9 | 8.8ms | **8.5ms** | **0.97x** |
| **H-only** | 50 | 9.5ms | **3.3ms** | **0.35x** |
| **C-only** | 30 | 9.3ms | **5.6ms** | **0.61x** |
| TM complex | 31 | 11.0ms | 18.3ms | 1.66x |

### 8.5 분석

**Expansion 내부의 Python loop가 핵심 병목:**

| Group | Output irreps | CG Instructions | CUDA Kernels |
|-------|:------------:|:---------------:|:------------:|
| sp | 2 | 6 | 12 |
| spd | 3 | 19 | 38 |
| spdf | 4 | 40 | 80 |
| **합계 (multi)** | — | 65 | **130** |
| **단일 (spd)** | 3 | 19 | **38** |

Multi-head는 kernel 수가 3.4배 → GPU parallelism으로 상쇄되지 않음.

### 8.6 실용적 판단

| 상황 | 추천 |
|------|------|
| def2-SVP, 유기 분자만 | Single head (14-dim) — 충분히 빠르고 간단 |
| H가 많은 분자 (50%+) | Fast Multi 유리 (sp head가 3x 빠름) |
| Transition metal 소수 + 유기 다수 | 2-group 분리 (sp / spd+) 최적 |
| def2-TZVP 이상 확장 시 | Multi-head 도입 검토 (padding 낭비 커짐) |

---

## 9. 파일 위치

| 파일 | 설명 |
|------|------|
| `QHFlow2/src/common/irrep_decompose.py` | `IrrepDecomposer` 클래스 |
| `QHFlow2/tests/test_irrep_decompose.py` | 8개 테스트 (equivariance 증명 포함) |
| `QHFlow2/tests/test_equivariant_normalization.py` | Normalization equivariance 검증 |
| `QHFlow2/experiments/test_multihead_expansion.py` | MoE MultiHead 기본 검증 (v1) |
| `QHFlow2/experiments/test_multihead_v2.py` | FastExpansion + throughput 벤치마크 (v2) |

---

## 10. 참고 문헌

- **SLEM**: Zhu et al., "Learning Local Equivariant Representations for Quantum Operators", ICLR 2025. [arXiv:2407.06053](https://arxiv.org/abs/2407.06053)
- **MACE-H**: "Equivariant Electronic Hamiltonian Prediction with Many-Body Message Passing", 2025. [arXiv:2508.15108](https://arxiv.org/abs/2508.15108)
- **EquiformerV2**: Liao et al., "EquiformerV2: Improved Equivariant Transformer", ICLR 2024.
- **Delta Project**: Lejaeghere et al., Science 351, 2016.
- **QHFlow**: Kim et al., "High-order Equivariant Flow Matching for DFT Hamiltonian Prediction", NeurIPS 2025 Spotlight.
