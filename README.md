# Remote Profile

Kubernetes 컨테이너 환경을 위한 영구 프로필 관리.

## 사용법

컨테이너가 새로 생성되면:

```bash
source /home1/irteam/data-vol1/profile/setup.sh
```

## 구조

```
profile/
├── setup.sh          # 부트스트랩 (이것만 실행하면 됨)
├── bashrc.d/         # 모듈별 bash 설정
│   ├── env.sh        #   환경변수
│   ├── aliases.sh    #   alias
│   ├── prompt.sh     #   프롬프트
│   └── functions.sh  #   유틸 함수
├── gitconfig         # git 설정
├── install.sh        # 패키지 자동 설치
├── bin/              # 커스텀 스크립트
└── .gitignore
```
