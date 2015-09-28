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

trap 'savelog -c 28 -n $LOGFILE > /dev/null' EXIT

if [ ! -f $pidfile ] ;then
   trap 'rm -f $pidfile > /dev/null 2>&1; savelog -c 28 -n $LOGFILE > /dev/null' EXIT
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
