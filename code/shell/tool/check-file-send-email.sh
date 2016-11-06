#!bin/sh

#file_type = "remote"
file_type="local"
alerm_msg="BJM_query_fail"

#path="http://nj03-game-m22dianquan68.nj03.baidu.com:8989/"
#file="data-20160820nei"

path="/home/users/yaokun/netdisk/code/work/crawler/bmj/"
file="err_file"

#file="data-20160818"
receiver="yaokun@baidu.com;"

if [ $file_type"" == "local" ]; then
    cp $path$file .
else
    wget $path$file
fi

if [ $? -eq 0 ]; then
    count=`cat $file | wc -l`
    echo $count
    if [ $count -gt 1 ]; then
        mutt -s $alerm_msg -c $receiver <<< "flag file : "$path$file", msg : "`cat $file`
        echo "real success";
    else
        echo "empty file";
    fi
    rm -rf $file
    #rm -rf $path$file
else
    echo "not ready"
fi
