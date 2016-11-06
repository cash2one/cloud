#!bin/sh

ZOOKEEPER_PATH="/home/users/yaokun/netdisk/usr/zookeeper"
ZOOKEEPER_DATA_PATH="/home/users/yaokun/netdisk/data/zookeeper"

DEFAULT_HOST=`hostname -i`
DEFAULT_PORT=2181

echo "ZooKeeper data Path : "$ZOOKEEPER_DATA_PATH

while getopts "cls" arg
do
    case $arg in
        c) echo "change the conf"
            vim $ZOOKEEPER_PATH/conf/zoo.cfg
            ;;
        l) echo "open the client"
            echo $ZOOKEEPER_PATH/bin/zkCli.sh connect $DEFAULT_HOST":"$DEFAULT_PORT
            ;;
        s) echo "start the server"
            $ZOOKEEPER_PATH/bin/zkServer.sh start
            ;;
    esac
done

