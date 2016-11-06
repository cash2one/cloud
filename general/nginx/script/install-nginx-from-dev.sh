echo "Checking if Openresty already exist"

PWD=`pwd`
WORK_ROOT="/home/work/yaokun"
OPENRESTY_ROOT=$WORK_ROOT/usr
OPENRESTY_HOME=$OPENRESTY_ROOT/openresty
DEP_PATH=$WORK_ROOT/usr/dep

TAR_HOST="yaokun@cp01-rdqa-dev340.cp01.baidu.com"
TAR_FILE="/home/users/yaokun/netdisk/download/openresty-1.9.15.1.tar.gz"
LDCONFIG_FILE="/home/users/yaokun/netdisk/download/ldconfig"
PCRE_FILE="/home/users/yaokun/netdisk/download/pcre-8.39.tar.gz"
NGINX_CONF_FILE="/home/users/yaokun/netdisk/bak/nginx/nginx.conf"
NGINX_LUA_KAFKA_LIB="/home/users/yaokun/netdisk/download/lua-resty-kafka"

if [ ! -f "/tmp/tmp-openresty.tar.gz" ]; then
    echo -e "------Start copy it------"
    scp $TAR_HOST:$TAR_FILE /tmp/tmp-openresty.tar.gz
fi

cd /tmp

# tar xzf /tmp/tmp-openresty.tar.gz -C $OPENRESTY_ROOT

cd $OPENRESTY_ROOT

TAR_DIR_NAME=`ls | grep "openresty-"`

if [ ! "t"$TAR_DIR_NAME = "t" ]; then
    mv $TAR_DIR_NAME openresty
fi

echo -e "Let us configure it"

# check ldconfig exist

which ldconfig > /dev/null

if [ $? -gt 0 ]; then
    echo "ldconfig do not exist, scp here"
    scp $TAR_HOST:$LDCONFIG_FILE $WORK_ROOT/../.jumbo/bin
    exit 0
fi

echo "check pcre"

if [ ! -x $DEP_PATH/pcre ]; then
    mkdir -p $DEP_PATH
    scp $TAR_HOST:$PCRE_FILE $DEP_PATH/pcre.tar.gz
    cd $DEP_PATH
    tar xvzf pcre.tar.gz
    rm -rf pcre.tar.gz
    PCRE_HOME=`ls | grep pcre`
    PCRE_HOME=`pwd`/$PCRE_HOME
    echo $PCRE_HOME
fi

cd $OPENRESTY_HOME

./configure --prefix=$OPENRESTY_HOME --with-pcre=$PCRE_HOME

make && make install

echo -e "Copy the nginx.conf file here"
mkdir -p $OPENRESTY_HOME/nginx/conf/lua
scp $TAR_HOST:$NGINX_CONF_FILE $OPENRESTY_HOME/nginx/conf/

echo -e "install openresty-kafka-lib"
mkdir -p $OPENRESTY_HOME/third-lib
scp -r $TAR_HOST:$NGINX_LUA_KAFKA_LIB $OPENRESTY_HOME/third-lib/

cd $PWD
