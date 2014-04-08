import subprocess, os, shutil, re, fileinput

# run as root, from the queen
# MOST IMPORTANT THING: replace the worker list with the actual worker list, which you can find in /home/beehive/cluster-management/hosts on the queen. I also add the queen IP to this list so that I can clear the queen's cache.
# to execute:  python clear_caches.py

workerlist=["39.64.8.3", "39.64.8.8", "39.64.8.9", "39.64.8.13", "39.64.8.15"]

def clear_caches():
		
	for index in range(len(workerlist)):
		print 'clearing caches (sync, echo 3> proc/sys/vm/drop_caches) for worker %s' % workerlist[index] 
		cmd=["ssh", workerlist[index], "sync"]
		process=subprocess.Popen(cmd, shell=False).wait()
		cmd=["ssh", workerlist[index], "echo 3> /proc/sys/vm/drop_caches"]
		process=subprocess.Popen(cmd, shell=False).wait()
		print 'done'
clear_caches()
print 'all caches cleared'
