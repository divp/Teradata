. $BENCHMARK_PATH/exports.sh

set -o nounset 

find -exec chown root {} \;
find -exec chgrp root {} \;
find -type d -exec chmod 755 {} \;
find -type f -exec chmod 744 {} \;
find -type f -name \*.sh -exec chmod 755 {} \;
find -type f -and -not -name \*.sh -exec chmod 644 {} \;

