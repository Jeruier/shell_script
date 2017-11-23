#!/bin/bash
#nginx编译安装
#@author Zhangrui
#created 2017/11/22
#email 1170870297@qq.com
NGINX_URL='http://nginx.org/download/nginx-1.8.1.tar.gz' #nginx下载地址
INSTALL_PKG_DIR='/usr/local/src' #安装包存放目录
INSTALL_DIR='/usr/local/nginx' #安装目录
SBIN_PATH='/usr/local/nginx/sbin/nginx' #指向（执行）程序文件（nginx）
CONF_PATH='/usr/local/nginx/conf/nginx.conf' #指向配置文件（nginx.conf）
ERROR_LOG_PATH='/var/log/nginx/error.log' #指向错误日志目录
ACCESS_LOG_PATH='/var/log/nginx/access.log' #设定access log路径
PID_PATH='/var/run/nginx/nginx.pid' #指向pid文件（nginx.pid）
echo '开始编译安装nginx...'

echo '正在安装必要依赖库...'
yum -y install gcc gcc-c++ automake pcre pcre-devel zlip zlib-devel openssl openssl-devel 

echo '正在下载nginx源码包...'
wget ${NGINX_URL}

echo '解压nginx源码包...'
tar -xzvf nginx-1.8.1.tar.gz -C ${INSTALL_PKG_DIR}
 
echo '切换到nginx安装包...'
cd ${INSTALL_PKG_DIR}/nginx-1.8.1/

#判断www用户组是否添加
grep -E "^www" /etc/group >& /dev/null
if [ $? != 0 ]; then
	echo '添加用户组...'
	groupadd www
fi
#判断www用户是否添加
id www
if [ $? != 0 ]; then
	echo '添加用户...'
	useradd -g www -s /sbin/nologin -M www
elif [ $(groups zr|awk -F ':' '{print $2}'|sed s/[[:space:]]//g) != 'www' ]; then
	#改变用户组
	echo "改变www用户为www用户组.."
	usermod -g www www

fi


echo '开始编译...'
./configure  --prefix=${INSTALL_DIR} \
 --sbin-path=${SBIN_PATH} \
 --conf-path=${CONF_PATH} \
 --error-log-path=${ERROR_LOG_PATH} \
 --http-log-path=${ACCESS_LOG_PATH} \
 --pid-path=${PID_PATH} \
 --user=www \
 --group=www \
 --with-http_ssl_module \
 --with-http_stub_status_module \
 --with-http_gzip_static_module \
 --with-pcre


 make && make install


echo '安装完毕!'

echo '启动nginx...'
${SBIN_PATH}

echo 'nginx版本:'
${SBIN_PATH} -v


