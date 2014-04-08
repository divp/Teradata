
# this requires the date and time stamp for the run
# as parm 1, so a typical call would be
# ./flatsar.sh 010912_0652
[ -x sarstat.out ] && rm sarstat.out
find ./ -name sarDEV_$1.log > flatsarlist.sh
sed -i 's/.\//awk -f flattensar.awk .\//' flatsarlist.sh
sed -i 's/.log/.log >> sarstat.out/' flatsarlist.sh
chmod 777 flatsarlist.sh
./flatsarlist.sh
sed -i "s/(/${1},(/" sarstat.out
