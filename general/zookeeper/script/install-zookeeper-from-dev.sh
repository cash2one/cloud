#!bin/sh

# fix the zookeeper.out path

ZOOKEEPER_SRC_HOST="yaokun@cp01-rdqa-dev340.cp01.baidu.com"
ZOOKEEPER_SRC_PATH="/home/users/yaokun/netdisk/download"

ZOOKEEPER_BASIC_CONF_FILE="/home/users/yaokun/netdisk/bak/zookeeper/zoo.cfg-basic"

TAR_FILE_NAME="zookeeper-3.4.8.tar.gz"

ZOOKEEPER_ROOT=""
ZOOKEEPER_HOME=""

ZK_SCRIPT_INSERT_LINE="123,124"

WORK_ROOT="/home/users/yaokun/netdisk"

PWD=`pwd`

while getopts "p:" arg
do
    case $arg in
        p)
            ZOOKEEPER_ROOT=$OPTARG
            ZOOKEEPER_HOME=$ZOOKEEPER_ROOT/zookeeper
            ;;
        ?)
            echo "unknown argument"
            exit 1
            ;;
    esac
done

if [ $ZOOKEEPER_HOME"t" = "t" ]; then
    echo "ZOOKEEPER_HOME is empty, please specify USE -p"
    exit 1
fi

if [ ! -f "/tmp/$TAR_FILE_NAME" ]
then
    scp $ZOOKEEPER_SRC_HOST:$ZOOKEEPER_SRC_PATH/$TAR_FILE_NAME /tmp/$TAR_FILE_NAME
    :
fi

if [ -x $ZOOKEEPER_HOME/bin/zkServer.sh ]; then
    echo -e "zookeeper has already exist"
    exit 0
fi

cd $WORK_ROOT/usr

tar xf /tmp/$TAR_FILE_NAME -C $WORK_ROOT/usr

old_dir_name=`ls | grep zookeeper`
mv $old_dir_name "zookeeper"

scp $ZOOKEEPER_SRC_HOST:$ZOOKEEPER_BASIC_CONF_FILE $ZOOKEEPER_HOME/conf/zoo.cfg

mkdir -p $WORK_ROOT/log/zookeeper
mkdir -p $WORK_ROOT/data/zookeeper

echo "dataDir=$WORK_ROOT/data/zookeeper" >> $ZOOKEEPER_HOME/conf/zoo.cfg
echo "dataLogDir=$WORK_ROOT/log/zookeeper" >> $ZOOKEEPER_HOME/conf/zoo.cfg

HOST=`hostname -i`
PORT1="2889"
PORT2="3889"

echo "server.1=$HOST:$PORT1:$PORT2" >> $ZOOKEEPER_HOME/conf/zoo.cfg
echo "server.2=$HOST:$PORT1:$PORT2" >> $ZOOKEEPER_HOME/conf/zoo.cfg

echo "1" > $WORK_ROOT/data/zookeeper/myid

# set the log dit path
# sed "$ZK_SCRIPT_INSERT_LINE i/ZOO_LOG_DIR="$($GREP "^[[:space:]]*dataLogDir" "$ZOOCFG" | sed -e 's/.*=//')"

cd $PWD
