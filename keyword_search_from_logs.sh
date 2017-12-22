#!/bin/bash
#author Zhangrui
#2017/12/22
#用于记录的很多日志关键词查找内容
dir='/data/www/b2b2c/logs/You163Callback' #默认查找的日志存放目录
name=''

write(){

    read -p '请输入需要查找的关键词：' keyw
    if [ ! ${keyw} ]; then
        write
    else
        name=${keyw}
    fi
}

#输入目录
if [ $1 ];then
    dir=$1
fi

if [ ! -d ${dir} ];then
    echo '输入的目录不存在...'
    exit 1
fi

write

echo '关键词查找结果:'
echo '------------------------------'

cd ${dir}
for file in $(ls ${dir})
do
    cat -n ${file} | grep --color $name
    if [ $? == 0 ]; then
        echo '文件路径:'
        echo "${dir}/${file}"
        echo '------------------------------'
    fi
done

echo 'finsh!'
