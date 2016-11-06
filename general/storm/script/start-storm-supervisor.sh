#!bin/sh

STORM_LOG_PATH="/home/users/yaokun/netdisk/log/storm"

# ps -ef | grep storm | grep -v grep | awk '{print $2}' | xargs kill -9

nohup storm supervisor &
# > $STORM_LOG_PATH/storm-supervisor-nohup.log
