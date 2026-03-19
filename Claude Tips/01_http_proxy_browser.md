# 서버에서 HTML을 브라우저로 보는 방법 (VSCode Proxy)

## 개요
NCloud ML Platform의 VSCode Server 환경에서는 `VSCODE_PROXY_URI`를 통해
컨테이너 내부 포트를 외부 브라우저에서 접근할 수 있다.

## 방법

### 1. HTTP 서버 실행
```bash
# 원하는 포트(예: 9000)로 서버 실행
python3 -m http.server 9000 --directory /path/to/html
```

### 2. 브라우저에서 접속
`VSCODE_PROXY_URI` 환경변수의 `{{port}}` 부분을 실제 포트 번호로 대체:
```
https://kpb4r.mlxp.ncloud.com/notebook/p-material-foundation/test3/proxy/9000/
```

### 3. 프록시 URL 확인 방법
```bash
echo $VSCODE_PROXY_URI
# 출력: https://kpb4r.mlxp.ncloud.com/notebook/p-material-foundation/test3/proxy/{{port}}/
```

## 참고
- 포트 번호는 자유롭게 선택 가능 (다른 서비스와 겹치지 않는 번호 사용)
- Jupyter, Streamlit, Gradio 등도 같은 방식으로 외부 접근 가능
- 예: Gradio를 7860 포트로 실행하면 → `proxy/7860/` 으로 접속
