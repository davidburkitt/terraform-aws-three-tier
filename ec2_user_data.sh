#!/bin/bash
yum -y update

# Install apache
yum -y install httpd
touch /var/www/html/index.html
chmod 777 /var/www/html/index.html
echo $(hostname) > /var/www/html/index.html
sed -i '0,/Listen 80$/s//Listen 8080/g' /etc/httpd/conf/httpd.conf
service httpd start 

# Install AWS logs for CloudWatch
yum install -y awslogs
sed -i '0,/us-east-1$/s//us-east-2/g' /etc/awslogs/awscli.conf
systemctl start awslogsd