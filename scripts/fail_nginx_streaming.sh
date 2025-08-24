# 1. NGINX RTMP MODULE 설치
git clone https://github.com/sergey-dryabzhinsky/nginx-rtmp-module.git


# 2. 의존성 설치
#   - build-essential
#   - libpcre3
#   - libpcre3-dev
#   - libssl-dev
sudo apt-get install build-essential libpcre3 libpcre3-dev libssl-dev

# 3. NGINX 다운로드
wget https://nginx.org/download/nginx-1.18.0.tar.gz
tar -xf nginx-1.18.0.tar.gz

# 4. NGINX 컴파일
## 4.1 configure : NGINX 내부 경로, 모듈, 컴파일 옵션 등이 정리됨
##   - --with-http_ssl_moudle : HTTPS/SSL 지원 모듈 활성화
##   - --add-module=../moudle : 외부 모듈을 NGINX에 추가
## 4.2 make : configure 단계에서 생성된 Makefile 기반으로 컴파일
##   - -j [number]: 병렬 빌드 스레드 수 지정

cd nginx-1.18.0
./configure --with-http_ssl_module --add-module=../moudle
# 에러 - OPENSSL의 버전 호환 문제로 인해 앞에 환경변수 추가하여
# 경로를 오류로 처리하지 않도록 변경, deprecated 함수 경고가 오류로 중단되지 않음
# CFLAGS="-Wno-error=deprecated-declarations" ./configure --with-http_ssl_module --add-module=../module

make -j 1
sudo make install