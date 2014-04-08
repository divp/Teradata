#!/bin/bash
source imapala_env.sh



echo "--------------------------------------------------------------------------------------"
echo "|                        Process to move files into cluster                          |"
echo "--------------------------------------------------------------------------------------"

echo "--> Copying files into cluster"
scp run_impala_queries.sh ea255008@10.25.12.249:$TPCDS_ROOT
scp load_db_impala_tpcds1000g.sql ea255008@10.25.12.249:$TPCDS_ROOT
scp imapala_env.sh ea255008@10.25.12.249:$TPCDS_ROOT

echo "--> Connecting into cluster"

ssh -D 1080 $TPCDS_USER@10.25.12.249