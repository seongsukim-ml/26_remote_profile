# K8s 컨테이너에서 브라우저로 HTML 보기

## 배경

Kubernetes 컨테이너(NCloud ML Platform) 안에서 작업할 때, 로컬 브라우저로 HTML 파일을 직접 열 수 없다.
VSCode Server가 제공하는 프록시 기능을 활용하면 컨테이너 내부 HTTP 서버에 외부 브라우저로 접근할 수 있다.

## 핵심 원리

컨테이너에 `VSCODE_PROXY_URI` 환경변수가 설정되어 있다:

```
VSCODE_PROXY_URI=https://kpb4r.mlxp.ncloud.com/notebook/p-material-foundation/test3/proxy/{{port}}/
```

컨테이너 내부에서 특정 포트로 HTTP 서버를 띄우면, `{{port}}`를 실제 포트 번호로 바꾼 URL로 브라우저에서 접근할 수 있다.

## 사용법

### 1. HTML 파일 준비

```bash
mkdir -p /home1/irteam/data-vol1/www
# index.html 등 파일을 www/ 디렉토리에 저장
```

### 2. HTTP 서버 실행

```bash
# 포트 9000에서 서버 시작 (백그라운드 실행)
python3 -m http.server 9000 --directory /home1/irteam/data-vol1/www &
```

### 3. 브라우저에서 접속

```
https://kpb4r.mlxp.ncloud.com/notebook/p-material-foundation/test3/proxy/9000/
```

### 4. 서버 종료

```bash
# 실행 중인 서버 확인
ss -tlnp | grep 9000

# 종료
kill $(lsof -t -i:9000)
# 또는
pkill -f "http.server 9000"
```

## 활용 예시

- Matplotlib/Plotly 차트를 HTML로 저장 후 브라우저에서 확인
- Jupyter notebook을 HTML로 export 후 공유
- 간단한 웹 대시보드 구동
- TensorBoard 등 웹 UI 도구 (포트만 바꿔서 동일하게 접근)

## 참고

- 포트는 다른 서비스와 충돌하지 않는 번호 사용 (현재 8888 등은 사용 중)
- `VSCODE_PROXY_URI` 값은 컨테이너가 재생성되면 바뀔 수 있으므로 `echo $VSCODE_PROXY_URI`로 확인
- 프록시 URL은 VSCode Server 인증을 거치므로 본인만 접근 가능
