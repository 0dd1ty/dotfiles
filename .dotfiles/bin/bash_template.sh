#!/usr/bin/env bash
set -euo pipefail
set -x

export EDITOR=mousepad

set +u
FILE=$1
set -u

for FILE in "$@"
do
printf "#!/usr/bin/env bash\n" > $FILE
chmod 755 $FILE
done;

$EDITOR $FILE