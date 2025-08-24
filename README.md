# Nginx 스트리밍 서버

Nginx로 스트리밍 서버를 세팅, 환경은 Linux가 필요

(현재 우분투 버전 : Ubuntu 22.04.5 LTS)

<br />

## Nginx 스트리밍 서버 세팅 (WSL Ubuntu 기준)

설치 후 URL로 접근하여 Nginx 서버가 제대로 나오는지 확인

```sh
# NGINX 설치
sudo apt update
sudo apt install nginx -y

# NGINX 버전 확인
nginx -v

# NGINX 상태 시작
sudo service nginx start
sudo systemctl start nginx

# NGINX 상태 확인
sudo service nginx status
sudo systemctl status nginx
```

<br />

## Nginx 스트리밍 모듈 빌드

```sh
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
```

<br />

## 기타 설정

```sh
#################################################
################ WLS Ubuntu 명령어 ###############
#################################################

#############################################################
# Linux에서 Windows 공유 폴더(CIFS/SMB) 마운트를 지원하는 유틸리티
# 설치 후 mount -t cifs 명령어를 통해서 Windows 네트워크 드라이브를 Linux에 연결 가능
apt install cifs-utils -y

# 사용 예시
# mount --> 파일 시스템을 특정 경로에 연결하는 Linux 명령어
# -t cifs --> CIFS/SMB 파일 시스템 타입으로 마운트 (Windows 공유)
# -o username=[사용자명],password=[비밀번호] --> 로그인 정보, 공유 폴더 접근을 위한 계정
# //192.168.0.157/STORAGE/ --> 원격 공유 폴더 경로 (Windows IP + 공유 이름)
# /mnt/proxy --> Linux에서 마운트할 로컬 경로
mount -t cifs -o username=[사용자명],password=[비밀번호] //192.168.0.157/STORAGE/ /mnt/proxy


#############################################################
# inet 부분의 주소 확인
ip addr show eth0


#################################################
############ Window PowerShell 명령어 ############
#################################################

## 관리자 권한 PowerSheel로 실행할 것 ##

# Portproxy(포트포워딩) 확인
netsh interface portproxy show all

# Portproxy(포트포워딩) 설정
netsh interface portproxy add v4tov4 listenport=80 listenaddress=0.0.0.0 connectport=80 connectaddress=172.23.73.94
## add                   --> 새로운 포트포워딩 규칙 추가
## v4tov4                --> IPv4 -> IPv4 포워딩, IPv4 수신 -> IPv4 전달
## listenport=80         --> Windows에서 수신할 포트
## listenaddress=0.0.0.0 --> Windows에서 수신할 IP (0.0.0.0는 모든 네트워크 인터페이스)
## connectport=80        --> 전달할 포트, 실제 서비스를 제공하는 포트(WSL Nginx의 포트)
## connectaddress        --> 전달할 대상 IP, WSL 내부 IP로 트래픽 전달 (ip addr show eth0로 확인한 IP)

# Portproxy(포트포워딩) 규칙 삭제
netsh interface portproxy delete v4tov4 listenport=80 listenaddress=0.0.0.0
```

<br />

## Nginx 설정 파일 (스트리밍 설정)

```conf
# Nginx 워커 프로세스 수 (CPU 코어 수에 맞게 조정 가능)
worker_processes  1;

events {
    # 각 워커 프로세스가 동시에 처리할 수 있는 최대 연결 수
    worker_connections  1024;
}

http {
    include             mime.types;                 # 파일 확장자별 MIME 타입 정의 포함
    default_type        application/octet-stream;   # MIME 타입이 정의되지 않은 파일의 기본 타입
    sendfile            on;                         # sendfile 사용하여 효율적인 파일 전송
    keepalive_timeout   65;                         # Keep-Alive 연결 유지 시간 (초 단위)

    # ================== VOD 모듈 관련 설정 ================== #
    vod_mode                            local;                  # 로컬 파일 기반 VOD 모드 사용
    vod_metadata_cache                  metadata_cache 16m;     # 메타데이터 캐시 크기 16MB
    vod_response_cache                  response_cache 512m;    # VOD 응답 캐시 크기 512MB
    vod_last_modified_types             *;                      # 모든 타입의 Last-Modified 헤더 사용
    vod_segment_duration                9000;                   # 동영상 세그먼트 길이 9초 단위
    vod_align_segments_to_key_frames    on;                     # 키 프레임 단위로 세그먼트 정렬
    vod_dash_fragment_file_name_prefix  "segment";              # DASH 세그먼트 파일 이름 접두사
    vod_hls_segment_file_name_prefix    "segment";              # HLS 세그먼트 파일 이름 접두사
    vod_manifest_segment_durations_mode accurate;               # 세그먼트 길이를 정확하게 계산

    # ================== 파일 캐시 관련 설정 ================== #
    open_file_cache                     max=1000 inactive=5m;   # 열린 파일 캐시 최대 1000개, 5분간 사용하지 않으면 제거
    open_file_cache_valid               2m;                     # 캐시 유효 시간 2분
    open_file_cache_min_uses            1;                      # 최소 1회 접근 시 캐시에 추가
    open_file_cache_errors              on;                     # 열기 실패한 파일도 캐시

    aio on; # 비동기 I/O 사용 (파일 읽기 성능 향상)

    # ================== 로그 설정 ================== #
    access_log  /var/log/nginx/access.log; # 접속 로그 경로
    error_log   /var/log/nginx/error.log;  # 에러 로그 경로

    # ================== 서버 블록 ================== #
    server {
                listen       80;            # HTTP 기본 포트
                server_name  localhost;     # 서버 이름 (호스트 이름)
                location /proxy/ {          # /proxy/ URL 경로로 접근하는 요청 처리
                        vod hls;            # VOD 모듈을 사용하여 HLS 스트리밍 제공
                        root /mnt/proxy;    # 동영상 파일이 있는 실제 경로

                        # CORS 설정 (다른 도메인에서도 접근 가능)
                        add_header Access-Control-Allow-Headers '*';
                        add_header Access-Control-Allow-Origin '*';
                        add_header Access-Control-Allow-Methods 'GET, HEAD, OPTIONS';
                }

                # ~             : 정규식 기반 경로 매칭
                # ^/videos/.+$  : URL이 /videos/로 시작하고 그 뒤에 하나 이상의 문자가 오는 경우, 경로 아래 모든 파일이나 하위 폴더 접근을 처리
                location ~ ^/videos/.+$ {
                    autoindex on; # 해당 디렉토리에 index.html이 없어도 파일 목록 표시
                                  # 브라우저에서 /videos/로 접속하면 폴더 안에 있는 동영상 파일 목록이 보임
                }
        }
}
```
