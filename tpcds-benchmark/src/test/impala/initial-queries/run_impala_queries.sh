echo "--------------------------------------------------------------------------------------"
echo "|                   Process to create data base and tables in Impala                  |"
echo "--------------------------------------------------------------------------------------"


echo "---> Running sql file "

impala-shell -i 10.25.12.43:21000 -f ./load_db_impala_tpcds1000g.sql

echo "---> End of process "