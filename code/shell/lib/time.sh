#!bin/sh

BUILD="True123"
START_DATE="20160901"
END_DATE="20160930"
SPLIT_SIZE=1
FILE_PREFIX="jdAndDuomeng_";
MR_QUEUE_NAME="default"
DATE_TAIL="%Y%m%d000000"
#MR_QUEUE_NAME="cbg"

# sql must contain QUERY_START_DATE and QUERY_END_DATE

TMP_DATE=$START_DATE
END_TIMESTAMP=`date -d "1 day$END_DATE" +"%s"`

BREAK_FLAG=0
while [ true ]
do
    QUERY_START_DATE=`date -d $TMP_DATE +$DATE_TAIL`
    QUERY_END_DATE=`date -d "$SPLIT_SIZE day "$TMP_DATE +$DATE_TAIL`
    QUERY_END_TIMESTAMP=`date -d ${QUERY_END_DATE:0:8} +"%s"`

    if [ $QUERY_END_TIMESTAMP -ge $END_TIMESTAMP ]; then
        QUERY_END_DATE=`date -d "1 day "$END_DATE +$DATE_TAIL`
        BREAK_FLAG=1
    else
        :
    fi
    FILE_NAME=$FILE_PREFIX"${QUERY_START_DATE:0:8}"_"${QUERY_END_DATE:0:8}.data"
    echo "File Name : "$FILE_NAME

    SQL="SELECT datee,ad_id,sum(case when (a_log_type=3) then 1 else 0 end) as show,sum(case when (a_log_type=2) then 1 else 0 end) as click,sum(case when (a_log_type=3) then a_price else 0 end) as price  from (SELECT distinct a.token, a.log_type as a_log_type, a.price as a_price, substr(cast(a.date as string),0,8) as datee,a.ader_id as ad_id FROM (select * from ad.ssp_log where log_type in (2,3) and ader_id in ('532766','1764323689') and dt>="$QUERY_START_DATE" and dt<"$QUERY_END_DATE")AS a LEFT JOIN (select * from ad.ssp_log where log_type = 1 and ader_id in ('532766','1764323689') and dt>="$QUERY_START_DATE" and dt<"$QUERY_END_DATE") AS b ON (a.token = b.token) WHERE ( unix_timestamp(cast(a.date as string), 'yyyyMMddHHmmss') - unix_timestamp(cast(b.date as string), 'yyyyMMddHHmmss') ) <= 21600 or ( unix_timestamp(cast(a.date as string), 'yyyyMMddHHmmss') - unix_timestamp(cast(b.date as string), 'yyyyMMddHHmmss') ) > 21600) tb group by ad_id,datee;"

    sql="set mapred.job.queue.name=$MR_QUEUE_NAME;$SQL"

    echo "Execute sql : [$sql]"

    if [ $BUILD == "True" ]; then
        hive -e "$sql" > /tmp/yaokun/$FILE_NAME
    fi

    if [ $BREAK_FLAG -eq 1 ]; then
        break
    fi
    TMP_DATE=`date -d "$SPLIT_SIZE day "$TMP_DATE +"%Y%m%d"`
done
