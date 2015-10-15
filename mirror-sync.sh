#!/bin/bash

##    Alejandro Suarez Cebrian (Responsable de la Oficina de Software Libre de la Universidad de Zaragoza)
##    Copyright (C) 2015  Alejandro Suarez Cebrian
##
##    This program is free software: you can redistribute it and/or modify
##    it under the terms of the GNU General Public License as published by
##    the Free Software Foundation, either version 3 of the License, or
##    any later version.
##
##    This program is distributed in the hope that it will be useful,
##    but WITHOUT ANY WARRANTY; without even the implied warranty of
##    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
##    GNU General Public License for more details.
##
##    You should have received a copy of the GNU General Public License
##    along with this program.  If not, see <http://www.gnu.org/licenses/>.
##

# Exit on errors and unset variables
set -e
set -u

log () {
   echo "$(date --rfc-3339=seconds) [$PID] $@"
}

export PATH='/usr/local/bin:/usr/bin:/bin:/usr/local/sbin:/usr/sbin:/sbin'

if [[ $# -ne 1 ]]
  then echo "Error: Missing arguments"
  echo
  echo "   Usage: $0 config-file.conf"
  exit 1
fi

source $1
PID=$$
SHARED_LOCK_DIR=$(dirname "$SHARED_LOCK")

# Log all activity to file.
exec >> $LOGFILE 2>&1
#trap 'savelog -c 28 -n $LOGFILE > /dev/null' EXIT

# Creating PID file
if ! ( set -o noclobber; echo "$PID" > "${PIDFILE}") 2> /dev/null; then
   log "PID file exists, update already running, stopping."
   exit 1
fi
trap 'rm -f $PIDFILE > /dev/null 2>&1; savelog -c 28 -n $LOGFILE > /dev/null' EXIT
   
# Create SHARED_LOCK directory
if ! ( mkdir -p -m a+w "$SHARED_LOCK_DIR" ) ; then 
   log "Error while creating SHARED LOCK folder, stopping."
   exit 1
fi

# Check if another synchronization proccess is running
if [ "$(ls -A $SHARED_LOCK_DIR )" ] ; then
   log "SHARED_LOCK files exists in $SHARED_LOCK_DIR, another update proccess already running, waiting $TIMEOUT seconds."
fi

DATE=$(date +%s)
while [ "$(ls -A $SHARED_LOCK_DIR )" ] && [ $(( $(date +%s) - $DATE )) -lt $TIMEOUT  ] ; do
   sleep $((60 + $RANDOM/1024))
done
  
if [ "$(ls -A $SHARED_LOCK_DIR )" ] ; then
   log "SHARED_LOCK files still exists in $SHARED_LOCK_DIR, another update proccess already running, we've waited for $TIMEOUT seconds, running anyway."
fi

# Creating SHARED_LOCK file
trap 'rm -f $PIDFILE > /dev/null 2>&1; rm -f $SHARED_LOCK > /dev/null 2>&1; savelog -c 28 -n $LOGFILE > /dev/null' EXIT
echo $PID > "$SHARED_LOCK"

log "Starting to sync from master repository @ '$SRC'..."
if nice -n $NICE_LEVEL ionice -c$IONICE_CLASS -n$IONICE_LEVEL rsync $RSYNC_OPTS $SRC/ $DEST/ ;then 

   LC_ALL=POSIX LANG=POSIX date -u > $DEST/lastsync
   date >> $DEST/lastsync
   log "Finished sync succesfuly"
else
   log "Error syncing"
fi


exit 0
