#!/bin/bash
### WORK IN PROGRESS ###

USER=2
SCALE=1000
DATADIR=data
TPLDIR=Htpl

TS=`date +%F_%H%M`
SCRIPT_PATH=`pwd`
OUTPUT_PATH=$SCRIPT_PATH/output_${DATABASE}_$TS
HIVE_CONFIG=$SCRIPT_PATH/hive_params_opt.sh
QUERY_PATH=/data/tpcds/GoodScripts/3000g/user01
DATABASE=orc_tpcds3000g



echo `ssh 1700cop1 "date \"+%Y-%m-%d %T \""` ">>> Test starts "
for  file in ${TPLDIR}/*.tpl ;
do

set -f

filename=`basename $file | cut -f1 -d'.'`

DATA=`head -n ${USER} ${DATADIR}/${SCALE}G/${filename}.dat | tail -n 1`
QRY=`cat $file`


case "${filename}" in

  tact1) 
    STS=$DATA
    QRY=$(echo ${QRY} | sed -e "s/\${STN}/${STN}/g") 
  ;;

  tact2) 
    STN=`echo ${DATA} | cut -f1 -d','`
    SIS=`echo ${DATA} | cut -f2 -d','`
    QRY=$(echo ${QRY} | sed -e "s/\${STN}/${STN}/g")
    QRY=$(echo ${QRY} | sed -e "s/\${SIS}/${SIS}/g")
  ;;

  tact3) 
    SSS=$DATA
    QRY=$(echo ${QRY} | sed -e "s/\${SSS}/${SSS}/g")
  ;;

  tact4)
    SC=`echo ${DATA} | cut -f1 -d','`
    SSN=`echo ${DATA} | cut -f2 -d','`
    QRY=$(echo ${QRY} | sed -e "s/\${SC}/${SC}/g")
    QRY=$(echo ${QRY} | sed -e "s/\${SSN}/${SSN}/g")
  ;;

  tact5)
    SIS=`echo ${DATA} | cut -f1 -d','`
    SSK=`echo ${DATA} | cut -f2 -d','`
    QRY=$(echo ${QRY} | sed -e "s/\${SIS}/${SIS}/g")
    QRY=$(echo ${QRY} | sed -e "s/\${SSK}/${SSK}/g")
  ;;

  tact6) 
    SIS=`echo ${DATA} | cut -f1 -d','`
    SSK=`echo ${DATA} | cut -f2 -d','`
    SS=`echo ${DATA} | cut -f3 -d','`
    DD=`echo ${DATA} | cut -f4 -d','`
    QRY=$(echo ${QRY} | sed -e "s/\${SIS}/${SIS}/g")
    QRY=$(echo ${QRY} | sed -e "s/\${SSK}/${SSK}/g")
    QRY=$(echo ${QRY} | sed -e "s/\${SS}/${SS}/g")
    QRY=$(echo ${QRY} | sed -e "s/\${DD}/${DD}/g")
  ;;

  *) echo "boo"
  ;;
  
esac

set +f

  cat $HIVE_CONFIG > $OUTPUT_PATH/$filename.hql
  cat $query >> $OUTPUT_PATH/$filename.hql
  chmod 755 $OUTPUT_PATH/$filename.hql
  sudo -u hdfs hive --database $DATABASE -f $OUTPUT_PATH/$filename.hql  2> $OUTPUT_PATH/$filename.err > $OUTPUT_PATH/$filename.out

done

echo `ssh 1700cop1 "date \"+%Y-%m-%d %T \""` "<<< Test ends "
