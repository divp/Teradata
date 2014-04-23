#!/bin/bash

set -o errexit

function finish {
    kill -SIGKILL $(jobs -p) 2>/dev/null
    #echo "Loops: $counter"
    find $BMS_OUTPUT_PATH -name tmp.\* -exec rm {} \; 2>/dev/null
}

counter=0

trap finish EXIT

. $BENCHMARK_PATH/exports.sh

if [ ! -d $BMS_OUTPUT_PATH ]
then
    echo "BMS output path ($BMS_OUTPUT_PATH) does not exist"
    exit 1
fi

FILE_SIZE_KB=10000
while (( 1 )) # *** infinite loop - worker must be killed by invoking driver
do
    counter=$(( $counter+1 ))
    f=$(mktemp $BMS_OUTPUT_PATH/tmp.XXXXXXXX)
    case $(( $RANDOM % 3 )) in
    0) 
        
        dd if=/dev/zero of=$f bs=1024 count=$FILE_SIZE_KB
        rm $f
        ;;
    1) 
        dd if=/dev/urandom of=$f bs=1024 count=$FILE_SIZE_KB | base64 > $f
        rm $f
        ;;
    2)
        i=0
        x=$RANDOM; y=$RANDOM; z=$RANDOM; acc=0
        while (( $i < 100000 ))
        do
            #nums=( $(od -v -An -N4 -tu2 < /dev/urandom) )
            #echo $(( ${nums[0]} * ${nums[1]} / 17 ** 2 )) > /dev/null
            acc=$(( $acc + ($x**2 * $y**2) / ($z * 17 + $i) ))
            [[ $RANDOM < 100 ]] && echo $acc >> $f
            i=$(( $i+1 ))
        done
        ;;
    esac
done

#while [ ! -f /tmp/stop-stress ]
#do
#    case $(( $RANDOM % 2 )) in
#    0) 
#        dd if=/dev/zero of=$f bs=1024 count=400000
#        ;;
#    1) 
#        dd if=/dev/urandom of=$f bs=1024 count=400000 | base64 > $f
#        ;;
#    esac
#    rm $f
#done