. $BENCHMARK_PATH/exports.sh

function log {
    echo "[$(date)] ($0) $* "
}

function banner {
    echo "================================================="
    echo "$*"
    echo "================================================="
}

echo
echo

banner "BMS diagnostics"

banner "env"
env

banner "CL Args"
echo $*

banner "df"
df -h

banner  "mount"
mount -l


