awk -f flattenvm.awk ./wrk3/vmstat_051412_1321.log >> vmstat.out
awk -f flattenvm.awk ./wrk4/vmstat_051412_1321.log >> vmstat.out
awk -f flattenvm.awk ./ldr1/vmstat_051412_1321.log >> vmstat.out
awk -f flattenvm.awk ./wrk6/vmstat_051412_1321.log >> vmstat.out
awk -f flattenvm.awk ./wrk2/vmstat_051412_1321.log >> vmstat.out
awk -f flattenvm.awk ./queen/vmstat_051412_1321.log >> vmstat.out
awk -f flattenvm.awk ./wrk5/vmstat_051412_1321.log >> vmstat.out
awk -f flattenvm.awk ./wrk1/vmstat_051412_1321.log >> vmstat.out
