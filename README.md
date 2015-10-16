Mirror-synchronizer
===================

Shell script to synchonize from a rsync server

Usage
-----
`./mirror-sync.sh config-file.conf`
`./mirror-check.sh config-file.conf`

Features
--------

 * Independent config files for different mirrors
 * Keep logs of what is happening
 * Lockfile to avoid synchonizations to run simultaneously
 * Shared lock folder (avoid different repositories to sync at the same time)
 * Rsync custom options
 * Custom nice and ionice levels for the rsync process

