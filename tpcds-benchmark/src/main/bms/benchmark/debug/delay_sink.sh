. $BENCHMARK_PATH/exports.sh

echo "Test stub"
DELAY=$1
echo "Delay mean: $DELAY s"
DELAY_DEV=$2
echo "Delay dev: $DELAY_DEV s"
shift; shift
for i in "$@"
do
        echo $i
done
d=$((  $DELAY + $DELAY_DEV - (  2 * ($RANDOM % $DELAY_DEV) ) ))
if [[ $RANDOM -lt 10000 ]]
then
        echo "ERROR: plain out of luck"
else
        echo "Sleeping $d sec"
        sleep $d
fi
