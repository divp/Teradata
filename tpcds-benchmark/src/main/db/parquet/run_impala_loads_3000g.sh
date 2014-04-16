echo "--------------------------------------------------------------------------------------"
echo "|                   Process to create data base and tables in Impala                  |"
echo "--------------------------------------------------------------------------------------"


echo "---> Running sql file "

impala-shell -i 10.25.12.43:21000 -f ./load_dims_db_parquet_tpcds3000g.sql
impala-shell -i 10.25.12.43:21000 -f ./load_facts_db_parquet_tpcds3000g.sql

echo "---> End of process "
