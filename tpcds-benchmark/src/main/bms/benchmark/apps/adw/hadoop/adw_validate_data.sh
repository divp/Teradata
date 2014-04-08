SCRIPT=$(basename $0)

LOG=/var/opt/benchmark/${SCRIPT}.sh.out

rm -f $LOG

date

echo "adw_associate 10239 
adw_district 52 
adw_item 8121 
adw_item_inventory 130421402 
adw_location 206 
adw_return_transaction_line 2670123 
adw_sales_transaction_temp 212993494
adw_sales_transaction 212993494
adw_sales_transaction_line_temp 7071498126
adw_sales_transaction_line 7071498126" | 
while read line
do
    x=( $line )
    t=${x[0]}
    c=${x[1]}
    hive -e "select '$t' as table_name, count(*) as act_row_count, $c as exp_row_count from $t;"
done | tee -a $LOG

date

