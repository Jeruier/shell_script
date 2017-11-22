#!/bin/bash
#安装mysql
#@author Zhangrui
#created 2017/11/9
#email 1170870297@qq.com
MYSQL_PATH='/usr/local/mysql'    #mysql所在目录 默认情况下是安装在/usr/local/mysql
MYSQL_DATA_PATH='/data/mysql'   #mysql数据存放目录
UNZIPED_MYSQL_PATH='' 		 #安装包解压后用于安装mysql的mysql安装包目录
INPUT_URL=$1 			#用户输入的mysql下载链接
MYSQL_DEFAULT_DOWNLOAD_URL='https://dev.mysql.com/get/Downloads/MySQL-5.6/mysql-5.6.38.tar.gz'  #mysql默认下载链接
MYSQL_DOWNLOAD_URL=''          #mysql下载链接
DOWNLOAD_TMP_DIR='/tmp/install_mysql'   #mysql安装包下载存放目录
MYSQL_PORT=3306  		#MySQL 监听端口
UNIX_ADDR="${MYSQL_PATH}/mysql.sock" #Unix socket 文件路径
SYSCONF_DIR='/etc' 		#系统配置目录
DOWNLOAD_RENAME='mysql-package.tar.gz' #下载mysql安装包重命名名称
PASSWORD='zhangrui'   			#root初始密码
#判断是否输入mysql下载地址
if [ ${INPUT_URL} ]; then
#输入的作为mysql下载地址
	MYSQL_DOWNLOAD_URL=${INPUT_URL}	

else
#未输入(自定义)mysql下载链接
	MYSQL_DOWNLOAD_URL=${MYSQL_DEFAULT_DOWNLOAD_URL}	

fi

echo "获取mysql下载链接：${MYSQL_DOWNLOAD_URL}..."

#开始下载mysql
if [ ! -d ${DOWNLOAD_TMP_DIR} ]; then
	#安装包下载存放目录不存在，创建
	echo "创建目录${DOWNLOAD_TMP_DIR}..."
	mkdir -p ${DOWNLOAD_TMP_DIR}
fi

echo "切换到mysql安装包下载存放目录${DOWNLOAD_TMP_DIR}..."
cd ${DOWNLOAD_TMP_DIR}

echo "开始下载mysql安装包..."

if [ -f ${DOWNLOAD_RENAME} ]; then
	#安装包存在
	read -n 1 -p "mysql安装包已存在，是否重新下载 [Y/N]?" IS_DEL_PACKAGE
	echo ' '
	case ${IS_DEL_PACKAGE} in
		Y|y)
			rm -f ${DOWNLOAD_RENAME} 
			;;
		*)
			echo "将使用该安装包继续安装..."
			;;
	esac
fi

#下载安装包
if [ ! -f ${DOWNLOAD_RENAME} ]; then
	#下载安装包重命名为$DOWNLOAD_RENAME
	wget -v -O ${DOWNLOAD_RENAME} ${MYSQL_DOWNLOAD_URL}

fi


#是否下载成功
if [ $? != 0 ]; then
	echo 'Fail:mysql安装包下载失败...'
	exit 1
fi


#取出mysql安装包文件解压后的文件夹名称
UNZIPED_MYSQL_PATH=$(tar -tzf ${DOWNLOAD_RENAME} | awk -F "/" '{print $1}' | sed -n '1p')

#判断指定需要安装的mysql安装包是否解压过
if [ -d ${UNZIPED_MYSQL_PATH} ]; then
	read -n 1 -p "检测存在该安装包的压缩文件，是否重新解压替换 [Y|N]" IS_DEL_UNZIPED
	echo ''
	case ${IS_DEL_UNZIPED} in
		Y|y)
			echo "mysql安装压缩包重新解压..."
			rm -f ${UNZIPED_MYSQL_PATH}
			;;
		*)
			echo "将使用已存在的安装包继续安装..."
			;;
	esac

fi

#解压mysql安装包
if [ ! -d ${UNZIPED_MYSQL_PATH} ]; then
	echo "开始解压安装压缩包..."
	tar -zxvf ${DOWNLOAD_RENAME}
fi


#进入安装包目录准备安装
echo "切换目录到 ${UNZIPED_MYSQL_PATH}..."
cd ${UNZIPED_MYSQL_PATH}

###编译安装

#安装必要软件包
echo "开始安装必要的软件包..."
yum -y -v install  gcc gcc-c++ gcc-g77 autoconf automake zlib* fiex* libxml* ncurses-devel libmcrypt* libtool-ltdl-devel* make cmake

#添加mysql用户 用户组
echo "添加mysql用户..."
groupadd mysql
echo "添加mysql用户组..."
useradd -r -g mysql mysql


#创建mysql数据存放目录
echo "创建mysql数据目录"
mkdir -p ${MYSQL_DATA_PATH}

echo "改变mysql数据目录所有者、组为mysql"
#改变目录所有者
chown -R mysql:mysql ${MYSQL_DATA_PATH}   

#编译
echo "编译..."
cmake . \
-DCMAKE_INSTALL_PREFIX=${MYSQL_PATH} \
-DMYSQL_DATADIR=${MYSQL_DATA_PATH} \
-DSYSCONFDIR=${SYSCONF_DIR} \
-DWITH_MYISAM_STORAGE_ENGINE=1 \
-DWITH_INNOBASE_STORAGE_ENGINE=1 \
-DWITH_MEMORY_STORAGE_ENGINE=1 \
-DWITH_READLINE=1 \
-DMYSQL_UNIX_ADDR=${UNIX_ADDR} \
-DMYSQL_TCP_PORT=${MYSQL_PORT} \
-DENABLED_LOCAL_INFILE=1 \
-DWITH_PARTITION_STORAGE_ENGINE=1 \
-DEXTRA_CHARSETS=all \
-DDEFAULT_CHARSET=utf8 \
-DDEFAULT_COLLATION=utf8_general_ci

make && make install

#检测上一步是否执行成功
if [ $? != 0 ]; then
	echo 'Fail：mysql编译失败...'
	exit 2
fi

echo "切换mysql安装目录${MYSQL_PATH}"
cd ${MYSQL_PATH}
#改变目录所有者
chown -R mysql:mysql ${MYSQL_PATH}   

#初始化数据库
echo "初始化数据库..."
${MYSQL_PATH}/scripts/mysql_install_db --user=mysql --basedir=${MYSQL_PATH} --datadir=${MYSQL_DATA_PATH} --innodb_undo_tablespaces=16

#注册为服务
echo "注册为服务mysqld"
cp ${MYSQL_PATH}/support-files/mysql.server /etc/rc.d/init.d/mysqld

#使用默认配置文件
echo "使用默认配置文件"
cp -f ${MYSQL_PATH}/support-files/my-default.cnf /etc/my.cnf

#让chkconfig管理mysql服务
chkconfig --add mysqld

#开机启动
echo "设置开机启动"
chkconfig --level 35 mysqld on

#启动mysql
echo "启动mysql"
service mysqld start


#将mysql的bin加入到path中
echo "添加环境变量"
echo -e "PATH=${MYSQL_PATH}/bin:${MYSQL_PATH}/lib:\$PATH\nexport PATH" >> /etc/profile
export PATH

#使/etc/profile里的配置立即生效
echo "使/etc/profile里的配置立即生效"
source /etc/profile


read -s -p '请设置mysql的root账号密码:' on_key_pwd
if [ ${on_key_pwd} ]; then
	echo  ''
	PASSWORD=${on_key_pwd}
else
	echo '未输入密码，将使用默认密码!'
fi


echo "密码成功设为:${PASSWORD}"

mysqladmin -u root password "${PASSWORD}"

