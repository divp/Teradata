if [[ $# -lt 1 ]]
then	
	echo "Usage: load_all.sh <SCALEFACTOR>"	
	exit 1
fi
SCALEFACTOR=$1
run.sh call_center $SCALEFACTOR 1 1
run.sh catalog_page $SCALEFACTOR 1 1
run.sh catalog_sales $SCALEFACTOR 36 36
run.sh customer $SCALEFACTOR 1 1
run.sh customer_address $SCALEFACTOR 1 1
run.sh customer_demographics $SCALEFACTOR 1 1
run.sh date_dim $SCALEFACTOR 1 1
run.sh household_demographics $SCALEFACTOR 1 1
run.sh income_band $SCALEFACTOR 1 1
run.sh inventory $SCALEFACTOR 15 15
run.sh item $SCALEFACTOR 1 1
run.sh promotion $SCALEFACTOR 1 1
run.sh reason $SCALEFACTOR 1 1
run.sh ship_mode $SCALEFACTOR 1 1
run.sh store $SCALEFACTOR 1 1
run.sh store_sales $SCALEFACTOR 36 36
run.sh time_dim $SCALEFACTOR 1 1
run.sh warehouse $SCALEFACTOR 1 1
run.sh web_page $SCALEFACTOR 1 1
run.sh web_sales $SCALEFACTOR 36 36
run.sh web_site $SCALEFACTOR 1 1
