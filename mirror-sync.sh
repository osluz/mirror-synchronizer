#!/bin/bash
#################################################################
##########       UPDATE SCRIPT
#################################################################

export PATH='/usr/local/bin:/usr/bin:/bin:/usr/local/sbin:/usr/sbin:/sbin'

if [[ $# -ne 1 ]]
  then echo "Error: Missing arguments"
  echo
  echo "   Usage: $0 config-file.conf"
  exit 1
fi

source $1
PID=$$

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
   echo "$(date --rfc-3339=seconds) PID file exists, update already running, stopping."
fi

exit 0
