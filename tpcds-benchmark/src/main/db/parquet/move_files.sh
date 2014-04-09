#!/bin/bash
source impala_env.sh

EDGE_NODE=10.25.12.249

echo "--------------------------------------------------------------------------------------"
echo "|                        Process to move files into cluster                          |"
echo "--------------------------------------------------------------------------------------"

echo "--> Copying files into cluster"
scp run_impala_queries.sh $TPCDS_USER@$EDGE_ODE:$TPCDS_ROOT
scp load_db_impala_tpcds1000g.sql $TPCDS_USER@$EDGE_NODE:$TPCDS_ROOT
scp impala_env.sh $TPCDS_USER@$EDGE_NODE:$TPCDS_ROOT

echo "--> Connecting into cluster"

ssh -D 1080 $TPCDS_USER@$EDGE_NODE
