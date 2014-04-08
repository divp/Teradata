#!/bin/sh
set -o nounset

echo "($0): Load retail data into HDFS, start time: $(date)"

INFILE=$1
OUTPUT_DIR=$2
CHUNK_SIZE=$3 # 40000000
HDFS_BASE="$4" # /data/raw/retail/sales_transaction_line/
MAXPS=$5 # 25

SLEEP_LENGTH=2

if [[ ! -e $INFILE ]]
then
    echo "($0): ERROR - File $INFILE not found"
    exit 1
fi

if [[ ! -d $OUTPUT_DIR ]]
then
    echo "($0): Creating output directory $OUTPUT_DIR"
    mkdir -p $OUTPUT_DIR
fi

if [[ $? -ne 0  ]]
then
    echo "($0): ERROR - Unable to create output directory $OUTPUT_DIR"
    exit 1
fi

if [[ ! -d $OUTPUT_DIR ]]; then
    echo "($0): ERROR - Output directory $OUTPUT_DIR not found"
    exit 1
fi

if [[ -z $INFILE || -z $OUTPUT_DIR || -z $CHUNK_SIZE || -z $MAXPS ]]
then
    echo "($0): ERROR - invalid arguments. Expecting:
    \$1: Input file path
    \$2: Split output directory path
    \$3: Chunk size (lines)
    \$4: Maximum loader processes"
    exit 1
fi

SPLIT_FILE_STEM=$(basename $INFILE)_split_

#Split input file into N million row chunks and start load process
echo "($0): Splitting up ${INFILE} into $CHUNK_SIZE line chunks with stem ${SPLIT_FILE_STEM} in dir ${OUTPUT_DIR}"
####################################
# Do the split...
####################################
rm -f ${OUTPUT_DIR}/*
split --suffix-length 4 -l ${CHUNK_SIZE} $INFILE ${OUTPUT_DIR}/${SPLIT_FILE_STEM} &
SPLIT_PID=$!

####################################
# Load the split files into HDFS
####################################
FLCNT=0
PREV_LINECT=0
rm /tmp/sales_transaction_line*lock

HDFS_PATH=${HDFS_BASE}/sales_transaction_line
hadoop fs -rmr ${HDFS_PATH}/ 2>/dev/null
hadoop fs -mkdir ${HDFS_PATH}

while ((1))
do
    FIRST_OPEN_SPLIT=$(ls ${OUTPUT_DIR}/${SPLIT_FILE_STEM}[a-z][a-z]* 2>/dev/null | grep -v '.loading$' | sort | head -1)
    DONE=$(ps -p $SPLIT_PID | wc -l)
    if [[ -z $FIRST_OPEN_SPLIT &&  $DONE -eq 1 ]] 
    then
        echo "($0): No pending splits found - exiting"
        break
    fi
    if [[ -z $FIRST_OPEN_SPLIT ]] 
    then
        echo "($0): No pending splits found - sleeping $SLEEP_LENGTH seconds"
        sleep $SLEEP_LENGTH
        continue
    fi
    LINE_COUNT=$(wc -l $FIRST_OPEN_SPLIT | cut -f1 -d' ')
    if [[ $LINE_COUNT -eq $CHUNK_SIZE ]] || [[ $(ps --pid $SPLIT_PID -o pid= | wc -l) -eq 0 ]]
    then
        echo "($0): Output split $FIRST_OPEN_SPLIT still open - sleeping $SLEEP_LENGTH seconds"
        sleep $SLEEP_LENGTH
    else
        echo "($0): Output split $FIRST_OPEN_SPLIT finished - loading into HDFS"
        PSCNT=$(ps -ef | grep hdfs_put.sh | wc -l)
        if [[ "$PSCNT" -gt "$MAXPS" ]]
        then
            echo "($0): Maximum number of parallel HDFS puts reached - sleeping $SLEEP_LENGTH seconds"
            sleep $SLEEP_LENGTH 
            continue
        fi
        echo "($0): Moving $FIRST_OPEN_SPLIT to $FIRST_OPEN_SPLIT.loading"
        STAGEFILE="$FIRST_OPEN_SPLIT.loading"
        BASENAME=$(basename $FIRST_OPEN_SPLIT)
        
        exec 8>/tmp/$BASENAME.lock
        if flock -x -n 8; then
            echo "($0): Loading $STAGEFILE into HDFS location: $HDFS_PATH"
            ( 
                mv $FIRST_OPEN_SPLIT $STAGEFILE
                hadoop fs -put $STAGEFILE $HDFS_PATH/$BASENAME
                rm $STAGEFILE 2>/dev/null
            ) &
        fi
    fi
done

echo "($0): Split files loaded into HDFS"
