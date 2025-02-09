# !/bin/bash
setenforce 0

# 의존성 패키지 설치
yum install -y epel-release
yum install -y https://rpms.remirepo.net/enterprise/remi-release-9.rpm

sudo yum module enable -y php:remi-8.1

yum install -y wget httpd php php-cli php-gd php-opcache php-curl php-mysqlnd

# Microsoft 패키지 리포지토리 설정
rpm --import https://packages.microsoft.com/keys/microsoft.asc
yum install -y https://packages.microsoft.com/config/rhel/9/packages-microsoft-prod.rpm

# Azure-CLI 설치
yum install -y azure-cli

az login --identity # 관리 ID로 로그인

# wordpress 패키지 다운로드 및 압축 해제
wget https://ko.wordpress.org/wordpress-5.8.8-ko_KR.tar.gz

# wordpress 구성 파일 경로 설정 (/var/www/html/)
tar xvfz wordpress-5.8.8-ko_KR.tar.gz
cp -ar ~/wordpress/* /var/www/html/

# wordpress 구성 파일 소유자/그룹 및 권한 변경
sudo chown -R apache:apache /var/www/html
sudo chmod -R 755 /var/www/html

# httpd.conf 설정 파일 내용 변경
sed -i 's/DirectoryIndex index.html/DirectoryIndex index.php/g' /etc/httpd/conf/httpd.conf

# wordpress 구성 파일(wp-config.php)에 DB 연동 정보 지정
DB_NAME="wordpress"
DB_USER="root"
export DB_PASSWORD=$(az keyvault secret show --vault-name keyvault-cus --name mysql-password --query value -o tsv)
DB_HOST="10.0.4.4" # Primary DB

cp /var/www/html/{wp-config-sample.php,wp-config.php}
sed -i "s/database_name_here/${DB_NAME}/g" /var/www/html/wp-config.php
sed -i "s/username_here/${DB_USER}/g" /var/www/html/wp-config.php
sed -i "s/password_here/${DB_PASSWORD}/g" /var/www/html/wp-config.php
sed -i "s/localhost/${DB_HOST}/g" /var/www/html/wp-config.php

# 워드프레스 설치 (URL: LB Public IP)
wp core install --url="http://123.45.67.89" \
    --title="sjwang" \
    --admin_user="admin" \
    --admin_password="Password4321!" \
    --admin_email="admin@gmail.com" \
    --path="/var/www/html"

# wordpress 실행
systemctl enable --now httpd