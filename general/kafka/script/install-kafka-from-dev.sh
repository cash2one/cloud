#!bin/sh

PWD=`pwd`
DEBUG=0 # for debugging

SCP_HOST="yaokun@cp01-rdqa-dev340.cp01.baidu.com"
SCP_KAFKA_TAR_PATH="/home/users/yaokun/netdisk/download/kafka_2.11-0.10.0.0.tgz"
SCP_KAFKA_CONF_PATH="/home/users/yaokun/netdisk/bak/kafka/server.properties-basic"
WORK_ROOT="/home/users/yaokun/netdisk"

while getopts "p:" arg
do
    case $arg in
        p)
            KAFKA_ROOT=$OPTARG
            KAFKA_HOME=$KAFKA_ROOT"/kafka"
            ;;
        ?)
            echo "unknown argument"
            exit 1
            ;;
    esac
done

if [ $KAFKA_HOME"t" = "t" ]; then
    echo "KAFKA_HOME is empty, please specify USE -p"
    exit 1
fi

if [ ! -f "/tmp/tmp-kafka.tgz" ]
then
    if [ $DEBUG -le 0 ]; then
        echo "------Now start copy it------"
        scp $SCP_HOST:$SCP_KAFKA_TAR_PATH /tmp/tmp-kafka.tgz
    fi
else
    echo "Kafka tar already exist!"
fi

if [ -x $KAFKA_HOME/bin/kafka-server-start.sh ]; then
    echo "Kafka already installed, now quit";
    exit 0
fi

cd /tmp

if [ $DEBUG -le 0 ]; then
    if [ ! -x "$KAFKA_HOME/bin/kafka" ]; then
        tar xzf tmp-kafka.tgz -C $KAFKA_ROOT
    fi
fi

cd $KAFKA_ROOT
if [ ! -x "$KAFKA_HOME/bin/kafka" ]; then
    mv `ls | grep kafka_` kafka
fi

scp $SCP_HOST:$SCP_KAFKA_CONF_PATH $KAFKA_HOME/config/server.properties

echo ""

mkdir -p $WORK_ROOT/log/kafka

HOST=`hostname -i`
PORT=9094

echo "listeners=PLAINTEXT://$HOST:$PORT" >> $KAFKA_HOME/config/server.properties
echo "port=$PORT" >> $KAFKA_HOME/config/server.properties
echo "zookeeper.connect=$HOST:2181" >> $KAFKA_HOME/config/server.properties
echo "log.dirs=$WORK_ROOT/log/kafka" >> $KAFKA_HOME/config/server.properties

mkdir -p $KAFKA_HOME/load
echo "nohup sh $KAFKA_HOME/bin/kafka-server-start.sh $KAFKA_HOME/config/server.properties $KAFKA_HOME/log/kafka/nohup.out &" >> $KAFKA_HOME/load/start.sh
echo "sh $KAFKA_HOME/bin/kafka-server-stop.sh $KAFKA_HOME/config/server.properties" >> $KAFKA_HOME/load/stop.sh
