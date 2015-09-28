#!/bin/bash
#################################################################
##########       UPDATE SCRIPT
#################################################################

export PATH='/usr/local/bin:/usr/bin:/bin:/usr/local/sbin:/usr/sbin:/sbin'

PID=$$
pidfile=/tmp/videolan.pid
SRC='rsync://rsync.videolan.org/videolan-ftp'  
DEST='/srv/repositorios/videolan'
#RSYNC_OPTS="--recursive --times --perms --links --delay-updates --delete-after --hard-links --compress --ipv4"
RSYNC_OPTS="--verbose --recursive --times --links --hard-links --perms --stats --delete-after --timeout=300 --compress --ipv4"
LOGFILE="/var/log/videolansync/videolan.log"

# Log all activity to file.
exec >> $LOGFILE 2>&1

trap 'rm -f $pidfile > /dev/null 2>&1; savelog -c 28 -n $LOGFILE > /dev/null' EXIT

if [ ! -f $pidfile ] ;then
   echo "$PID" >$pidfile
   #trap 'rm -f $pidfile' EXIT
   
   echo "$(date --rfc-3339=seconds) Starting to sync from master repository @ '$SRC'..."
   if rsync $RSYNC_OPTS $SRC/ $DEST/ ;then 

      LC_ALL=POSIX LANG=POSIX date -u > $DEST/lastsync
      date >> $DEST/lastsync
      echo "$(date --rfc-3339=seconds) Finished sync succesfuly"
   else
      echo "$(date --rfc-3339=seconds) Error syncing"
   fi

else
   echo "$(date --rfc-3339=seconds) PID file exists, videolan update already running, stopping."
fi

exit 0
