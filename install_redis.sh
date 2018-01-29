#!/bin/bash
VERSION='4.0.7'      #版本
INSTALL_DIR='/usr/local/redis'   #安装目录
PID_FILE='/var/run/redis.pid' #pid文件
PORT=6379    #端口号
DATA_DIR='/data/redis/'  #redis数据存放目录
PASSWD='zhangrui'  #连接密码

initial_dir=$(pwd)
echo '开始下载redis安装包...'
echo "版本：${VERSION}..."
wget http://download.redis.io/releases/redis-${VERSION}.tar.gz

if [ ! -f "redis-${VERSION}.tar.gz" ];then
	echo '源码包下载失败...'
	exit 1
fi

echo '开始解压...'
tar -zxvf redis-${VERSION}.tar.gz

cd redis-${VERSION}

echo '开始编译...'

make && make PREFIX=${INSTALL_DIR} install

mkdir -p ${INSTALL_DIR}/etc/

cp redis.conf ${INSTALL_DIR}/etc/

cd ${INSTALL_DIR}/bin/

cp redis-benchmark redis-cli redis-server /usr/bin/

if [ ! -d ${DATA_DIR} ];then
	mkdir -p ${DATA_DIR}
fi

echo '修改redis配置...'
sed -i -e '/^daemonize/ c daemonize yes'\
 -e "/^pidfile/ c pidfile ${PID_FILE}"\
 -e "/^port/ c port ${PORT}"\
 -e "/^dir/ c dir ${DATA_DIR}"\
 -e "s/^# requirepass foobared/requirepass ${PASSWD}/"\
 ${INSTALL_DIR}/etc/redis.conf


echo "添加环境变量..."
echo -e "PATH=\$PATH:${INSTALL_DIR}/bin\nexport PATH" >> /etc/profile
export PATH


rm -rf ${initial_dir}/redis-${VERSION}.tar.gz ${initial_dir}/redis-${VERSION}

echo "Redis-${VERSION}安装完成!"



