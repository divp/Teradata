set -o nounset



DIR=/var/opt/benchmark
if [ ! -d /var/opt/benchmark ]
then
	echo "ERROR: data directory $DIR cannot be found"
	exit 1
fi