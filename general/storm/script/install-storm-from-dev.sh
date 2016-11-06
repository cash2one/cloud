#!bin/sh

# install jumbo

echo -e "Install python/java"

jumbo install python
jumbo install sun-java7

PWD=`pwd`
DEBUG=0 # for debugging

SCP_HOST="yaokun@cp01-rdqa-dev340.cp01.baidu.com"
SCP_STORM_TAR_PATH="/home/users/yaokun/netdisk/download/apache-storm-0.9.6.tar.gz"
WORK_ROOT="/home/work/yaokun"

while getopts "p:" arg
do
    case $arg in
        p)
            STORM_ROOT=$OPTARG
            STORM_HOME=$STORM_ROOT"/storm"
            ;;
        ?)
            echo "unknown argument"
            exit 1
            ;;
    esac
done

if [ "t"$STORM_ROOT = "t" ];then
    echo "STORM_ROOT empty, please use -p to specify!"
    exit 1
fi

echo -e "Storm Home is [\033[44;30m"$STORM_HOME"\033[0m]"

if [ ! -x "$STORM_HOME/bin/storm" ]
then
    echo "Storm not exist!";
else
    echo "Storm exist, do not need to install";
    if [ $DEBUG -le 0 ]; then
        exit 0;
    fi
fi

if [ ! -f "/tmp/tmp-storm.tar.gz" ]
then
    if [ $DEBUG -le 0 ]; then
        echo "------Now start copy it------"
        scp $SCP_HOST:$SCP_STORM_TAR_PATH /tmp/tmp-storm.tar.gz
    fi
else
    echo "Storm tar already exist!"
fi

cd /tmp

if [ $DEBUG -le 0 ]; then
    if [ ! -x "$STORM_HOME/bin/storm" ]; then
        mkdir -p $STORM_ROOT
        tar xzf tmp-storm.tar.gz -C $STORM_ROOT
    fi
fi

cd $STORM_ROOT
if [ ! -x "$STORM_HOME/bin/storm" ]; then
    # change the name
    mv `ls | grep apache` storm
fi

# back to the work dir
cd $PWD

PYTHON_BIN=`which python`
sed -i "1d" $STORM_HOME/bin/storm
SED_OPT="1 i\#!$PYTHON_BIN"
sed -i "${SED_OPT}" $STORM_HOME/bin/storm

echo -e "\033[44;30m-----Generating storm.yaml-----\033[0m"
rm -rf $STORM_HOME/conf/storm.yaml
echo "storm.zookeeper.servers:" >> $STORM_HOME/conf/storm.yaml
echo '  - "1.1.1.1"' >> $STORM_HOME/conf/storm.yaml
echo 'nimbus.host: "1.1.1.1"' >> $STORM_HOME/conf/storm.yaml
echo "storm.local.dir: \"$WORK_ROOT/data/storm\"" >> $STORM_HOME/conf/storm.yaml
echo "storm.log.dir: \"$WORK_ROOT/log/storm\"" >> $STORM_HOME/conf/storm.yaml
echo 'supervisor.slots.ports:' >> $STORM_HOME/conf/storm.yaml
echo '  - 8991' >> $STORM_HOME/conf/storm.yaml
echo '  - 8992' >> $STORM_HOME/conf/storm.yaml

mkdir -p $WORK_ROOT/data/storm
mkdir -p $WORK_ROOT/log/storm

echo -e "\033[44;30m-----Generate load-----\033[0m"

mkdir -p $STORM_HOME/load
TMP_VAR="supervisor"
echo "nohup storm $TMP_VAR > $WORK_ROOT/log/storm/$TMP_VAR-nohup.log &" > $STORM_HOME/load/start-$TMP_VAR.sh
TMP_VAR="ui"
echo "nohup storm $TMP_VAR > $WORK_ROOT/log/storm/$TMP_VAR-nohup.log &" > $STORM_HOME/load/start-$TMP_VAR.sh
TMP_VAR="logviewer"
echo "nohup storm $TMP_VAR > $WORK_ROOT/log/storm/$TMP_VAR-nohup.log &" > $STORM_HOME/load/start-$TMP_VAR.sh
TMP_VAR="nimbus"
echo "nohup storm $TMP_VAR > $WORK_ROOT/log/storm/$TMP_VAR-nohup.log &" > $STORM_HOME/load/start-$TMP_VAR.sh

echo -e "\033[44;30m-----Setting env-----\033[0m"
if [ $DEBUG -le 0 ]; then
    echo "export STORM_HOME=$STORM_HOME" >> ~/.bashrc
    echo "export PATH=\$JAVA_HOME/bin:\$STORM_HOME/bin:/home/work/.jumbo/bin:/home/work/.jumbo/bin:/usr/kerberos/bin:/usr/local/bin:/bin:/usr/bin:/usr/X11R6/bin:/usr/share/baidu/bin:/opt/bin:/home/opt/bin:/DoorGod/bin" >> ~/.bashrc
    source ~/.bashrc
    vim $STORM_HOME/conf/storm.yaml
    exit 0
fi

echo "Debug:"
echo "export \$STORM_HOME=$STORM_HOME"
echo "export PATH=\$JAVA_HOME/bin:\$STORM_HOME/bin:/home/work/.jumbo/bin:/home/work/.jumbo/bin:/usr/kerberos/bin:/usr/local/bin:/bin:/usr/bin:/usr/X11R6/bin:/usr/share/baidu/bin:/opt/bin:/home/opt/bin:/DoorGod/bin"
exit 0
