# !/bin/bash
setenforce 0 

# MySQL 서버 설치 및 실행
yum install -y mysql-server
systemctl enable --now mysqld

# MySQL 서버 설치 시 openssh 와의 버전 호환 문제 방지
yum install -y openssh

# Secondary DB 서버 설정
cat <<EOF >> /etc/my.cnf
[mysqld]
server-id=2
relay-log=relay-log
read-only=1
EOF

# Primary 서버를 복제 소스로 설정
mysql -u root <<EOF
CHANGE MASTER TO
    MASTER_HOST='10.0.4.4',
    MASTER_USER='replica_user',
    MASTER_PASSWORD='Password5678!',
    MASTER_LOG_FILE='binlog.000001',
    MASTER_LOG_POS=123456;
START SLAVE;
EOF