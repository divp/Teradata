
# this requires the date and time stamp for the run
# as parm 1, so a typical call would be
# ./flatvm.sh 010912_0652
rm vmstat.out
find ./ -name vmstat_$1.log > flatvmlist.sh
sed -i 's/.\//awk -f flattenvm.awk .\//' flatvmlist.sh
sed -i 's/.log/.log >> vmstat.out/' flatvmlist.sh
chmod 777 flatvmlist.sh
./flatvmlist.sh
sed -i "s/(/${1},(/" vmstat.out
