#!/bin/bash

# run.sh <tablename> <number of streams> <pread #>

TABLENAME=$1
STREAMS=$2
PREAD=$3

rm -f /data/tpcds/pfast/${TABLENAME}.lst

if [ ${TABLENAME} == "store_sales" ] || [  ${TABLENAME} == "web_sales" ] || [  ${TABLENAME} == "catalog_sales" ] ; then 
	echo ok

elif [ ${STREAMS} -eq 1 ]; then
	echo 2
else 

for i in `seq 1 ${STREAMS}` 
do
	echo $i
done

fi

