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
# 예시에서는 inet이 192.168.112.28
ip addr show eth0
# 결과물
# 2: eth0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc mq state UP group default qlen 1000
#     link/ether 00:15:5d:50:4c:e6 brd ff:ff:ff:ff:ff:ff
#     inet 192.168.112.28/20 brd 192.168.127.255 scope global eth0
#        valid_lft forever preferred_lft forever
#     inet6 fe80::215:5dff:fe50:4ce6/64 scope link
#        valid_lft forever preferred_lft forever






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