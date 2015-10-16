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

if [[ -e $PIDFILE ]]; then
   echo 1
else
   echo 0
fi

exit 0
