#!/bin/bash
#编译安装php56
#@author Zhangrui
#created 2017/11/22
#email 1170870297@qq.com
DOWNLOAD_URL='http://cn2.php.net/distributions/php-5.6.32.tar.gz'  #php56下载链接
INSTALL_PKG_DIR='/usr/local/src' #安装包存放目录
INSTALL_DIR='/usr/local/php' #安装目录


echo '获取php安装包下载链接...'
echo '开始下载php安装包...'
wget  ${DOWNLOAD_URL}

tar -xzvf php-5.6.32.tar.gz -C ${INSTALL_PKG_DIR}
#添加epel源
rpm -Uvh http://dl.fedoraproject.org/pub/epel/6/x86_64/epel-release-6-8.noarch.rpm
 
echo '开始安装依赖包...'
 #安装所需依赖包
yum install -y gcc-c++ \
    zlib \
    zlib-devel \
    openssl \
    openssl-devel \
    pcre-devel \
    libxml2 \
    libxml2-devel \
    libcurl \
    libcurl-devel \
    libpng-devel \
    libjpeg-devel \
    freetype-devel \
    libmcrypt-devel \
    openssh-server \
    python-setuptools


echo '切换到安装包目录...'
cd ${INSTALL_PKG_DIR}/php-5.6.32

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

echo '开始编译...
'
./configure --prefix=${INSTALL_DIR} \
    --with-config-file-path=${INSTALL_DIR}/etc \
    --with-config-file-scan-dir=${INSTALL_DIR}/etc/php.d \
    --with-fpm-user=www \
    --with-fpm-group=www \
    --with-mcrypt=/usr/include \
    --with-mysqli \
    --with-pdo-mysql \
    --with-openssl \
    --with-gd \
    --with-iconv \
    --with-zlib \
    --with-gettext \
    --with-curl \
    --with-png-dir \
    --with-jpeg-dir \
    --with-freetype-dir \
    --with-xmlrpc \
    --with-mhash \
    --enable-fpm \
    --enable-xml \
    --enable-shmop \
    --enable-sysvsem \
    --enable-inline-optimization \
    --enable-mbregex \
    --enable-mbstring \
    --enable-ftp \
    --enable-gd-native-ttf \
    --enable-mysqlnd \
    --enable-pcntl \
    --enable-sockets \
    --enable-zip \
    --enable-soap \
    --enable-session \
    --enable-opcache \
    --enable-bcmath \
    --enable-exif \
    --enable-fileinfo \
    --disable-rpath \
    --enable-ipv6 \
    --disable-debug \
    --without-pear 


make -j && make install

#cp php.ini-development ${INSTALL_DIR}/etc/php.ini   #开发版本
cp php.ini-production ${INSTALL_DIR}/etc/php.ini     #线上版本

cp ${INSTALL_DIR}/etc/php-fpm.conf.default ${INSTALL_DIR}/etc/php-fpm.conf
cp ${INSTALL_DIR}/etc/php-fpm.d/www.conf.default ${INSTALL_DIR}/etc/php-fpm.d/default.conf

cp sapi/fpm/init.d.php-fpm /etc/init.d/php-fpm56

chmod +x /etc/init.d/php-fpm56 

echo '安装完毕!'

echo "添加环境变量..."
echo -e "PATH=\$PATH:${INSTALL_DIR}/bin\nexport PATH" >> /etc/profile
export PATH


echo '启动php-fpm56'
service php-fpm56 start

php -v

