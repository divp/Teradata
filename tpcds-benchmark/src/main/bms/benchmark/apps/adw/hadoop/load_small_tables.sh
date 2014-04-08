set -o nounset

SOURCE_BASE_PATH="$1"
HDFS_BASE_PATH="$2"
echo "Loading retail tables from '$1' into HDFS '$2'"

hadoop fs -rmr ${HDFS_BASE_PATH}
for f in associate district item item_inventory location return_transaction_line sales_transaction
do
    echo "[$(date +"%Y-%m-%d %H:%M:%S %Z")] Attempting 'hadoop fs -put ${SOURCE_BASE_PATH}/${f}.csv ${HDFS_BASE_PATH}/${f}/'"
    time hadoop fs -put ${SOURCE_BASE_PATH}/${f}.csv ${HDFS_BASE_PATH}/${f}/
    if [[ $? -eq 0 ]]
    then
        echo "[$(date +"%Y-%m-%d %H:%M:%S %Z")] HDFS put successful for ${SOURCE_BASE_PATH}/${f}.csv info hdfs:${HDFS_BASE_PATH}/${f}/"
    else
        echo "[$(date +"%Y-%m-%d %H:%M:%S %Z")] HDFS put failed for ${SOURCE_BASE_PATH}/${f}.csv info hdfs:${HDFS_BASE_PATH}/${f}/"
        exit 1
    fi
done