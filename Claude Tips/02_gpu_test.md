# GPU 작동 확인 방법

## 빠른 확인

```bash
# 드라이버 & GPU 상태 확인
nvidia-smi
```

## PyTorch로 상세 테스트

이 환경에서는 conda Python을 사용해야 PyTorch가 동작한다:

```bash
# 시스템 python3 (3.10) → PyTorch 없음
# conda python (3.11) → PyTorch 있음
/opt/conda/bin/python -c "
import torch
print(f'CUDA available: {torch.cuda.is_available()}')
print(f'GPU count: {torch.cuda.device_count()}')
for i in range(torch.cuda.device_count()):
    print(f'GPU {i}: {torch.cuda.get_device_name(i)}')
    props = torch.cuda.get_device_properties(i)
    print(f'  Memory: {props.total_memory / 1024**3:.1f} GB')
"
```

## 연산 테스트 (각 GPU에서 행렬곱 실행)

```bash
/opt/conda/bin/python -c "
import torch
for i in range(torch.cuda.device_count()):
    device = torch.device(f'cuda:{i}')
    a = torch.randn(1000, 1000, device=device)
    b = torch.randn(1000, 1000, device=device)
    c = torch.matmul(a, b)
    torch.cuda.synchronize(device)
    print(f'GPU {i}: OK')
print('ALL PASSED')
"
```

## 현재 서버 스펙

| 항목 | 값 |
|------|-----|
| GPU | NVIDIA H200 x 8 |
| GPU 메모리 | 139.8 GB each |
| CUDA | 12.8 |
| PyTorch | 2.10.0+cu128 |
| Compute Capability | 9.0 |

## 주의사항

- `python3`이 아닌 `/opt/conda/bin/python`을 사용할 것
- 또는 conda 환경을 활성화: `conda activate base`
