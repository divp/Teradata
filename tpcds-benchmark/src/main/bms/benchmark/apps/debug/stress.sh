#!/bin/bash

trap 'kill $(jobs -p) 2>/dev/null' EXIT

cpus=$(lscpu | grep '^CPU(s)' | awk '{print $2;}')

RUN_TIME=5

if [ $# -eq 0 ]
then
    echo "Assuming default run time of $RUN_TIME seconds"
else 
	if [ $# -eq 1 ]
	then
        RUN_TIME=$1
    	if [[ ! $1 =~ ^[0-9]+$ || $1 -lt 1 ]]
        then
            echo "Invalid parameter '$1'. Runtime seconds argument must be a decimal integer"
            exit 1
        fi
        echo "Using run time of $RUN_TIME seconds"
    else
        echo "Invalid parameters. Expecting one argument for run time seconds"
        exit 1
    fi
fi

echo "Starting load generators on $cpus CPUs"
pids=""
for i in $(seq 1 $cpus)
do
    $(dirname $0)/stress_worker.sh &
    child_pid=$!
    pids="$pids $child_pid"
done

#echo "Parent PID: $$, children PIDs: $pids"
sleep $RUN_TIME
#echo -n "Terminating child processes: "
for pid in $pids
do
    #echo -n "$pid "
    kill $pid
done
echo
wait

