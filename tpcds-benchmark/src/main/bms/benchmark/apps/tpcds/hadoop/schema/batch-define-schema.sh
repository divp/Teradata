
#
# Define the schema for the data ingest that was just performed
#
. ../etl_env.sh

#configuration

# echo "create_staging_tables.hql\n create_ssv_view.hql\n create_storv_view.hql" |

echo "create_staging_tables.hql" |
   xargs --verbose -r --max-args=1 --max-procs=1 \
     hive -v --database=$TARGET_DB \
	  --hivevar SOURCE_DB=$SOURCE_DB \
	  --hivevar TARGET=$TARGET \
	  --hivevar SCALE_FACTOR=$SCALE_FACTOR \
	  --hivevar BATCH=$BATCH -f
