#!/bin/bash
#author Zhangrui
#2017/12/9
#nginx日志分割
PID_PATH='/var/run/nginx/nginx.pid'  #pid文件位置
HTTP_LOG_PATH='/var/log/nginx/access.log' 
ERROR_LOG_PATH='/var/log/nginx/error.log'
CUT_NAME='cuted_logs' #存放分割日志的文件夹名称
COMP_NAME=$(date "+%Y_%m_%d_%H%M%S") #压缩文件的名称

#日志存放目录
http_log_dir="$(dirname ${HTTP_LOG_PATH})"
err_log_dir="$(dirname ${ERROR_LOG_PATH})"

http_log_cut_dir="${http_log_dir}/${CUT_NAME}"
error_log_cut_dir="${err_log_dir}/${CUT_NAME}"

#判断访问日志和错误日志是否相同
if [ ${http_log_cut_dir} == ${error_log_cut_dir} ]; then
	
	http_log_cut_dir="${http_log_cut_dir}/access_logs"
	error_log_cut_dir="${error_log_cut_dir}/error_logs"

fi

#压缩备份日志文件
if [ ! -d ${http_log_cut_dir} ]; then
	mkdir -p ${http_log_cut_dir}
fi

if [ ! -d ${error_log_cut_dir} ]; then
	mkdir -p ${error_log_cut_dir}
fi
access_tar_name=${COMP_NAME}access.log.tar.gz
cd ${http_log_dir} && tar -czPf ${access_tar_name} ${HTTP_LOG_PATH} && mv ${access_tar_name} ${http_log_cut_dir} && rm -rf ${HTTP_LOG_PATH}

error_tar_name=${COMP_NAME}error.log.tar.gz
cd ${err_log_dir} && tar -czPf ${error_tar_name} ${ERROR_LOG_PATH} && mv ${error_tar_name} ${error_log_cut_dir} && rm -rf ${ERROR_LOG_PATH}

kill -USR1 $(cat ${PID_PATH})
