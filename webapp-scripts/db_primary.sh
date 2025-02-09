# !/bin/bash
setenforce 0 

# MySQL 서버 설치 및 실행
yum install -y mysql-server
systemctl enable --now mysqld

# MySQL 서버 설치 시 openssh 와의 버전 호환 문제 방지
yum install -y openssh

# Primary DB 서버 설정
cat <<EOF >> /etc/my.cnf
[mysqld]
server-id=1
log-bin=mysql-bin
bind-address=10.0.4.4
EOF

# 웹 서버와 연동에 사용할 사용자 계정과 데이터베이스 생성 및
# DB 서버 복제를 위한 사용자 계정 생성
mysql -u root <<EOF
CREATE USER 'root'@'%' IDENTIFIED BY 'Password1234!';
GRANT ALL PRIVILEGES ON *.* TO 'root'@'%';
CREATE DATABASE wordpress;
CREATE USER 'replica_user'@'10.0.5.4' IDENTIFIED WITH 'mysql_native_password' BY 'Password5678!';
GRANT REPLICATION SLAVE ON *.* TO 'replica_user'@'10.0.5.4';
EXIT
EOF