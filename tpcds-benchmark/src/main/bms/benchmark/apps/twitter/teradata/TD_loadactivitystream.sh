mknod activity_stream.txt p
pigz -d -c activity_stream.txt.gz >activity_stream.txt &
sleep 2
fastload <activity_stream.fl >activity_stream.out 2>&1 

