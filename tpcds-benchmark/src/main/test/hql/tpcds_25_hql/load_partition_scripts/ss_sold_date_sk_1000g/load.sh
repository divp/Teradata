for sql in `cat filelist`
do
	echo "Loading $sql"
	sudo -u hdfs hive --database orc_part_tpcds1000g -i initialize.hql -f $sql
done
