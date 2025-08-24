# ================================================ #
# ================ 기존 NGINX 제거 ================ #
# ================================================ #

# 실행 중이면 중지 (systemctl이 안되면 service nginx stop)
sudo systemctl stop nginx

# 설정 파일 포함하여 전부 제거
sudo apt purge nginx nginx-common nginx-core -y

# 필요없는 의존성 제거
sudo apt autoremove -y

# 패키지 캐시 정리
sudo apt autoclean

# NGINX 설정 디렉토리, 로그 삭제
sudo rm -rf /etc/nginx      # 설정 
sudo rm -rf /var/log/nginx  # 로그
sudo rm -rf /var/lib/nginx  # 설정

# ================================================ #
# ================ 기존 NGINX 설치 ================ #
# ================================================ #

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