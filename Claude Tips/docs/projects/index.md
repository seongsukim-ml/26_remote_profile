# Project-specific Tips

프로젝트에 종속된 팁을 기록합니다. 서버 환경이나 일반 Python 설정과 달리, 특정 프로젝트의 워크플로우·트러블슈팅·노하우를 다룹니다.

## 구분 기준

| 구분 | General | Project |
|------|---------|---------|
| **대상** | 서버 환경, OS, 네트워크, conda/uv 등 | 특정 프로젝트의 코드, 데이터, 학습 |
| **예시** | HTTP Proxy 설정, GPU 테스트, conda 영속화 | QHFlow2 학습 재현, dft-viz 배포 |
| **수명** | 서버가 바뀌지 않는 한 유효 | 프로젝트 종료 시 아카이브 |

## Projects

| Project | 관련 팁 |
|---------|---------|
| QHFlow2 | *(아직 없음 — 추가 시 `projects/qhflow2/` 에 작성)* |
| dft-viz | *(아직 없음 — 추가 시 `projects/dft-viz/` 에 작성)* |

!!! tip "새 프로젝트 팁 추가"
    1. `docs/projects/<project-name>/` 디렉토리 생성
    2. `.md` 파일 작성
    3. `mkdocs.yml`의 `nav > Projects` 에 항목 추가
