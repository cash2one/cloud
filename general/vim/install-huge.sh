#!/bin/sh

REMOTE_TYPE="git"

OUTSIDE_GIT="https://git.oschina.net/1ove/cloud_huge.git";
#OUTSIDE_GIT="https://github.com/morysky/cloud_huge.git"

INSIDE_GIT="ssh://yaokun@icode.baidu.com:8235/baidu/yaokun/cloud_huge"
INSIDE_FILE="http://cp01-rdqa-dev340.cp01.baidu.com:8888/file/vim/"

IS_BAIDU=0
function checkBaiduEnv() {
    res=`hostname | grep "baidu.com"`
    if [ $res"" == "" ]; then
        :
    else
        IS_BAIDU=1
    fi
}

checkBaiduEnv

if [ $IS_BAIDU -eq 0 ]; then
    GIT_REP=$OUTSIDE_GIT
    FILE_HOST=$OUTSIDE_FILE
else
    GIT_REP=$INSIDE_GIT
    FILE_HOST=$INSIDE_FILE
    REMOTE_TYPE="file"
fi

USER_PWD=`pwd`
CUR=`dirname $0`
cd $CUR
CUR=`pwd`

#copy file

if [ -d /tmp/cloud_huge ]; then
    echo "Extension tmp dir already exists!";
    :
else
    if [ $REMOTE_TYPE == "git""" ]; then
        echo "Start cloning the huge file"
        git clone $GIT_REP /tmp/cloud_huge

        cp  /tmp/cloud_huge/vim/*.bz ~/.vim/bundle/

        cd ~/.vim/bundle

        tar xjf YCM-thirdparty.tar.bz
        tar xjf YouCompleteMe.tar.bz
        tar xjf neocomplete.tar.bz

        rm -rf YouCompleteMe/third_party/
        mv third_party/ YouCompleteMe/

        # manual process every plugin
        # todo

        rm -rf *.tar.bz
    else
        mkdir /tmp/cloud_huge
        cd /tmp/cloud_huge
        ext_list=("neocomplete.vim")
        for ext_name in ${ext_list[@]}
        do
            real_ext_name=$ext_list".tar.bz"
            wget $FILE_HOST$real_ext_name
            tar xjf $real_ext_name
            if [ -d ~/.vim/bundle/$ext_name ]; then
                :
            else
                mv $ext_name ~/.vim/bundle
            fi
        done
    fi
fi

rm -rf /tmp/cloud_huge

cd $USER_PWD
echo "Install huge extension Done!";
