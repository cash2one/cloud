#!/bin/sh

ext_list=("auto-pairs")

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
    :
else
    # first update vim
    jumbo install vim
fi

USER_PWD=`pwd`
CUR=`dirname $0`
cd $CUR
CUR=`pwd`

cp vimrc ~/.vimrc

if [ -d ~/.vim ]; then
    :
else
    mkdir ~/.vim
fi

cp tar/bundle.tar.bz ~/.vim/
cd ~/.vim
rm -rf bundle
tar xjf bundle.tar.bz
rm -rf bundle.tar.bz

cd $CUR
cd tar
for ext_name in ${ext_list[@]}
do
    tar xjf $ext_name".tar.bz"
    mv $ext_name ~/.vim/bundle/
done

cd $USER_PWD
echo "Install Done!";
