#!/bin/bash
set -e
echo 'generating new server keys with ssh-keygen -A'
echo 'ssh-keygen -A'
### useful for debugging ssh related issues
#rsyslogd
###
echo 'starting sshd deamon'
/usr/sbin/sshd -D && tailf /var/log/auth.log 2>&1 
