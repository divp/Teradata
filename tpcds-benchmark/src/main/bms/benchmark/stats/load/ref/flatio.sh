
# this requires the date and time stamp for the run
# as parm 1, so a typical call would be
# ./flatio.sh 010912_0652
rm iostat.out
find ./ -name iostat_$1.log > flatiolist.sh
sed -i 's/.\//awk -f flattenio.awk .\//' flatiolist.sh
sed -i 's/.log/.log >> iostat.out/' flatiolist.sh
chmod 777 flatiolist.sh
./flatiolist.sh
sed -i "s/(/${1},(/" iostat.out
