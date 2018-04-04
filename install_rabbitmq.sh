#!/bin/bash
#安装RabbitMq
#author Zhangrui
#date 2018/4/4
#email 1170870297@qq.com
INSTALL_DIR=/usr/local/rabbitmq  #rabbitmq安装目录
PHP_INSTALLED_DIR=/usr/local/php #已安装的php目录
TMP_DIR=/tmp #临时目录
cd ${TMP_DIR}
echo '安装RabbitMq脚本开始运行...';
echo '安装RabbitMq环境及必要支持...';
yum install -y ncurses-devel   unixODBC unixODBC-devel xmlto
echo ‘安装erlang环境...’
wget http://www.erlang.org/download/otp_src_17.3.tar.gz
tar -zxvf otp_src_17.3.tar.gz
echo "moving ${TMP_DIR}/otp_src_17.3/"
cd otp_src_17.3
echo '编译erlang...'
./configure --without-javac
make && make install

echo "moving ${TMP_DIR}"
cd ${TMP_DIR}
echo '下载RabbitMq源码包...'
wget http://www.rabbitmq.com/releases/rabbitmq-server/v3.4.1/rabbitmq-server-3.4.1.tar.gz
tar -zxvf rabbitmq-server-3.4.1.tar.gz
echo "moving ${TMP_DIR}/rabbitmq-server-3.4.1/"
cd rabbitmq-server-3.4.1/
echo '开始编译RabbitMq...'
make TARGET_DIR=${INSTALL_DIR} SBIN_DIR=${INSTALL_DIR}/sbin MAN_DIR=${INSTALL_DIR}/man DOC_INSTALL_DIR=${INSTALL_DIR}/doc install

echo '启动RabbitMq...'
${INSTALL_DIR}/sbin/rabbitmq-server  > /dev/null &
if [ $? == 0 ];then
    echo '启动RabbitMq [succ]'
else
    echo '启动RabbitMq [fail]'
fi

extend=$(${PHP_INSTALLED_DIR}/bin/php -m | grep -i rabbitmq)
if [ ${extend} ];then
    echo 'php已安装RabbitMq扩展 [end]'
    exit 0
 else
    echo 'php开始安装RabbitMq扩展...'
fi


echo "moving ${TMP_DIR}"
cd ${TMP_DIR}
echo '下载rabbitmq-c的包'
wget https://github.com/alanxz/rabbitmq-c/releases/download/v0.4.1/rabbitmq-c-0.4.1.tar.gz
echo '下载amqp的包...'
wget http://pecl.php.net/get/amqp-1.2.0.tgz
tar -zxvf rabbitmq-c-0.4.1.tar.gz
tar -zxvf amqp-1.2.0.tgz
echo ‘安装rabbitmq-c...’
echo "moving ${TMP_DIR}/rabbitmq-c-0.4.1/"
cd rabbitmq-c-0.4.1
echo '开始编译...'
./configure --prefix=/usr/local/rabbitmq-c
make && make install
echo "moving ${TMP_DIR}/amqp-1.2.0/"
cd ${TMP_DIR}/amqp-1.2.0
${PHP_INSTALLED_DIR}/bin/phpize
echo 'configure...'
./configure --with-php-config=${PHP_INSTALLED_DIR}/bin/php-config --with-amqp --with-librabbitmq-dir=/usr/local/rabbitmq-c-0.4.1/
echo '开始编译...'
make && make install

echo 'RabbitMq加入php扩展...'
phpini_file=${PHP_INSTALLED_DIR}/etc/php.ini
php_extend=$(sed -n '/extension=swoole.so/ p' ${phpini_file})
if [ ${extend} ];then
    echo 'php.ini的RabbitMq扩展已存在 [exist]'
else
    echo 'php.ini开始加入RabbitMq扩展...'
    echo 'extension=amqp.so' >> ${phpini_file}
fi

echo '重启php-fpm...'

php_fpm=$(ls /etc/rc.d/init.d/ | grep -i php-fpm)
if [ ${php_fpm} ];then
    service ${php_fpm} restart
else 
    ${PHP_INSTALLED_DIR}/sbin/php-fpm restart
fi

echo '清理临时目录、临时文件'
rm -rf ${TMP_DIR}/otp_src_17.3.tar.gz ${TMP_DIR}/otp_src_17.3/ ${TMP_DIR}/rabbitmq-server-3.4.1.tar.gz ${TMP_DIR}/rabbitmq-server-3.4.1/
rm -rf ${TMP_DIR}/rabbitmq-c-0.4.1.tar.gz ${TMP_DIR}/amqp-1.2.0.tgz ${TMP_DIR}/rabbitmq-c-0.4.1/ ${TMP_DIR}/amqp-1.2.0/
echo 'rabbitmq install [finish]'
