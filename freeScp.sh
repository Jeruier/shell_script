#!/bin/bash
#设置scp免密码连接ssh
#author Zhangrui
#created 2017/11/9

#判断/root/.ssh目录是否有写的权限
if [ ! -w /root/.ssh ]; then
	echo '无权限设置'
	exit 1
fi

echo "正在生成密钥..."
ssh-keygen -t rsa

if [ ! -f ~/.ssh/id_rsa.pub ]; then
	echo '密钥生成失败'
	exit 2
fi

echo '将密钥上传到远程服务器:'
read -p "请输入远程服务器的IP:" REMOTE_HOST_IP

if [ -z "${REMOTE_HOST_IP}" -o ! ${REMOTE_HOST_IP} ]; then
	echo "未输入服务器IP"
	exit 3
fi

read -p "请输入远程服务器的用户名:" REMOTE_HOST_NAME

if [ -z "${REMOTE_HOST_NAME}" -o ! ${REMOTE_HOST_NAME} ]; then
	echo "未输入服务器用户名"
	exit 4
fi

echo "请输入远程服务器的密码完成密钥传输..."

scp ~/.ssh/id_rsa.pub  ${REMOTE_HOST_NAME}@${REMOTE_HOST_IP}:/root/.ssh/authorized_keys

if [ $? == 0 ]; then
	echo "scp远程服务器免密连接建立成功"
fi

