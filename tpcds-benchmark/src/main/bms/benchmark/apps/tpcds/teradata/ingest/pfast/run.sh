#!/bin/bash

# run.sh <tablename> <scale> <number of streams> <pread #>

TABLENAME=$1
SCALE=$2
STREAMS=$3
PREAD=$4

rm -f /data/tpcds/pfast/${TABLENAME}.lst

rm -f /data/tpcds/pfast/store_returns.lst
rm -f /data/tpcds/pfast/web_returns.lst
rm -f /data/tpcds/pfast/catalog_returns.lst

if [ ${STREAMS} -eq 1 ]; then
        rm -f /data/tpcds/pfast/fifos/${TABLENAME}.dat
        mkfifo  /data/tpcds/pfast/fifos/${TABLENAME}.dat
        cd /data/tpcds/tools/
        /data/tpcds/tools/dsdgen -table ${TABLENAME} -delimiter \| -qu Y -force Y -scale ${SCALE} -dir /data/tpcds/pfast/fifos/  2>&1 &
        echo /data/tpcds/pfast/fifos/${TABLENAME}.dat >> /data/tpcds/pfast/${TABLENAME}.lst

else 

for i in `seq 1 ${STREAMS}` 
do
	rm -f /data/tpcds/pfast/fifos/${TABLENAME}_${i}_${STREAMS}.dat
	mkfifo  /data/tpcds/pfast/fifos/${TABLENAME}_${i}_${STREAMS}.dat
	cd /data/tpcds/tools/
	if [ ${TABLENAME} == "store_sales" ]  ; then
		rm -f /data/tpcds/pfast/fifos/store_returns_${i}_${STREAMS}.dat
		mkfifo  /data/tpcds/pfast/fifos/store_returns_${i}_${STREAMS}.dat
		echo /data/tpcds/pfast/fifos/store_returns_${i}_${STREAMS}.dat >> /data/tpcds/pfast/store_returns.lst
	fi
        if [ ${TABLENAME} == "catalog_sales" ]  ; then
                rm -f /data/tpcds/pfast/fifos/catalog_returns_${i}_${STREAMS}.dat
                mkfifo  /data/tpcds/pfast/fifos/catalog_returns_${i}_${STREAMS}.dat
                echo /data/tpcds/pfast/fifos/catalog_returns_${i}_${STREAMS}.dat >> /data/tpcds/pfast/catalog_returns.lst
        fi
        if [ ${TABLENAME} == "web_sales" ]  ; then
                rm -f /data/tpcds/pfast/fifos/web_returns_${i}_${STREAMS}.dat
                mkfifo  /data/tpcds/pfast/fifos/web_returns_${i}_${STREAMS}.dat
                echo /data/tpcds/pfast/fifos/web_returns_${i}_${STREAMS}.dat >> /data/tpcds/pfast/web_returns.lst
        fi

	/data/tpcds/tools/dsdgen -table ${TABLENAME} -delimiter \| -qu Y -force Y -scale ${SCALE} -dir /data/tpcds/pfast/fifos/ -child ${i} -parallel ${STREAMS} 2>&1 &
	echo /data/tpcds/pfast/fifos/${TABLENAME}_${i}_${STREAMS}.dat >> /data/tpcds/pfast/${TABLENAME}.lst
done
fi

sleep 1
cd /data/tpcds/pfast

if [ ${TABLENAME} == "store_sales" ]  ; then
/opt/teradata/pfast2/bin/master -f ${TABLENAME}.mc -ic 1 -ai-file_list /data/tpcds/pfast/${TABLENAME}.lst -ai-pread n -ai-inst_count ${PREAD} > ${TABLENAME}.m.log 2>&1 &
/opt/teradata/pfast2/bin/master -f store_returns.mc -ic 1 -ai-file_list /data/tpcds/pfast/store_returns.lst -ai-pread n -ai-inst_count ${PREAD} > store_returns.m.log 2>&1 &

elif [  ${TABLENAME} == "web_sales" ]; then 
/opt/teradata/pfast2/bin/master -f ${TABLENAME}.mc -ic 1 -ai-file_list /data/tpcds/pfast/${TABLENAME}.lst -ai-pread n -ai-inst_count ${PREAD} > ${TABLENAME}.m.log 2>&1 &
/opt/teradata/pfast2/bin/master -f web_returns.mc -ic 1 -ai-file_list /data/tpcds/pfast/web_returns.lst -ai-pread n -ai-inst_count ${PREAD} > web_returns.m.log 2>&1 &


elif  [  ${TABLENAME} == "catalog_sales" ] ; then 
/opt/teradata/pfast2/bin/master -f ${TABLENAME}.mc -ic 1 -ai-file_list /data/tpcds/pfast/${TABLENAME}.lst -ai-pread n -ai-inst_count ${PREAD} > ${TABLENAME}.m.log 2>&1 &
/opt/teradata/pfast2/bin/master -f catalog_returns.mc -ic 1 -ai-file_list /data/tpcds/pfast/catalog_returns.lst -ai-pread n -ai-inst_count ${PREAD} > catalog_returns.m.log 2>&1 &


else 
/opt/teradata/pfast2/bin/master -f ${TABLENAME}.mc -ic 1 -ai-file_list /data/tpcds/pfast/${TABLENAME}.lst -ai-pread n -ai-inst_count ${PREAD} > ${TABLENAME}.m.log 2>&1 &
fi 

wait
