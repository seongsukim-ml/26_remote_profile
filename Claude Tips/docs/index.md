# Claude Tips

Claude와 함께 서버를 운영하면서 알게 된 것들을 기록하는 지식 베이스입니다.

## 이 사이트의 역할

| 항목 | 설명 |
|------|------|
| **무엇을** | Claude와의 대화에서 나온 유용한 설정, 해결법, 노하우 |
| **왜** | 같은 문제를 다시 만났을 때 빠르게 참고하기 위해 |
| **어디서** | `/home1/irteam/data-vol1/Claude Tips/docs/` 에 마크다운으로 저장 |
| **어떻게** | MkDocs Material로 빌드 → VSCode Proxy로 브라우저에서 열람 |

!!! tip "새 팁 추가 방법"
    1. `docs/카테고리/` 에 `.md` 파일 생성
    2. `mkdocs.yml`의 `nav`에 항목 추가
    3. `mkdocs build` 실행 (또는 `mkdocs serve`로 자동 반영)

## 카테고리

### Server
서버 환경 설정, 네트워크, GPU 관련 팁

- [HTTP Proxy로 브라우저 접근](server/http_proxy.md) — VSCode Proxy를 이용한 웹 서비스 접근
- [HTTP 서버 실행](server/http_server.md) — Python HTTP 서버 띄우기
- [GPU 테스트](server/gpu_test.md) — PyTorch로 GPU 동작 확인

### Python
Python 환경 및 패키지 관리

- [Persistent Conda](python/persistent_conda.md) — 컨테이너 재시작 후에도 유지되는 conda 환경
- [Conda + uv 함께 사용하기](python/conda_uv.md) — conda와 uv를 조합한 빠른 패키지 관리

### Data
데이터 및 파일 관리

- [data-vol1 디렉토리 구조](data/directory_structure.md) — 영구 볼륨의 폴더 구성과 역할

### Projects
프로젝트 관련 노하우

- [PySCF vs e3nn Convention](projects/pyscf_e3nn_convention.md) — 구면 조화 함수 순서/축 차이와 최적화
