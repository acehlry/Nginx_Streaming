# 패키지 목록 업데이트
apt update
# 시스템 패키지 최신화
apt upgrade -y


# 필요 의존성 설치
apt install curl -y             # 파일 다운로드, 외부 요청
apt install build-essential -y  # GCC, make 등 컴파일 필수 도구
apt install libssl-dev -y       # OpenSSL 개발 헤더, HTTPS 지원용
apt install zlib1g-dev -y       # 압축 관련 라이브러리
apt install linux-generic -y    # 최신 안정화 커널, 관련 패키지를 설치 및 유지
apt install libpcre3 -y         # 정규식 처리용(Nginx 필요)
apt install libpcre3-dev -y     # 정규식 처리용(Nginx 필요)
apt install ffmpeg -y           # 동영상 처리를 위한 라이브러리
apt install libavcodec-dev -y   # 동영상 처리를 위한 라이브러리
apt install libavformat-dev -y  # 동영상 처리를 위한 라이브러리
apt install libswscale-dev -y   # 동영상 처리를 위한 라이브러리

# NGINX VOD 모듈 다운로드
git clone https://github.com/kaltura/nginx-vod-module.git

# NGINX 소스 다운로드 및 압축 해제(버전 선택)
wget http://nginx.org/download/nginx-1.16.1.tar.gz
tar -xzvf nginx-1.16.1.tar.gz
cd nginx-1.16.1

wget https://nginx.org/download/nginx-1.18.0.tar.gz
tar -xf nginx-1.18.0.tar.gz
cd nginx-1.18.0

# NGINX 빌드

CFLAGS="-Wno-error=deprecated-declarations" # OpenSSL 함수 오류 무시

./configure \
  --add-module=../nginx-vod-module \        # Kaltura VOD 모듈을 Nginx에 추가 (HLS/DASH 스트리밍 지원)
  --with-threads \                          # Nginx 워커 스레드 지원 활성화 (멀티스레드 I/O 처리 가능)
  --with-cc-opt="-O3 -mpopcnt" \            # GCC 컴파일러 최적화 옵션
                                            # -O3 : 최고 수준 최적화
                                            # -mpopcnt : CPU의 POPCNT 명령어 활용 (비트 카운팅 최적화)
  --with-cc-opt="-DNGX_VOD_MAX_TRACK_COUNT=256 -mavx2" \  
                                            # -DNGX_VOD_MAX_TRACK_COUNT=256 : VOD 모듈 최대 트랙 수 256 설정
                                            # -mavx2 : CPU AVX2 명령어 활용 (벡터 연산 최적화)
  --with-file-aio \                         # 비동기 파일 입출력(AIO) 활성화 (HDD/SSD I/O 효율 향상)
  --with-http_ssl_module                    # HTTPS/SSL 모듈 활성화 (TLS/SSL 지원)

make -j 1       # 스레드 수 지정
make install    # 빌드

# 설정파일 적용
# 미리 세팅한 nginx.conf를 기본 nginx.conf로 변경 
sudo cp [directory_path]/nginx.conf /usr/local/nginx/conf/nginx.conf

# NGINX 설정 문법 검사
sudo /usr/local/nginx/sbin/nginx -t