echo "Clearing Cache on Data Nodes..."
#Clear on Local Node
free -m; 
sync; echo 3 > /proc/sys/vm/drop_caches;
free -m;
for node in `cat cluster_nodes`
do
	echo "--$node--"
	ssh $node "free -m; sync; echo 3 > /proc/sys/vm/drop_caches;free -m;"
done
echo "Complete."
