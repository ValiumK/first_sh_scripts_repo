#!/bin/sh
echo Backup conf
CMD="/bin/tar"
RCMD="ssh root@server"
DIRS="etc/"
cd /; $CMD -cjf - $DIRS | $RCMD "cat > `hostname`.backup_conf.`date '+%Y%m%d'`.tbz" 
