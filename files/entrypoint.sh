#!/bin/bash

/etc/init.d/snmpd start
#/usr/sbin/snmpd -f -Lsd -Lf /dev/null -u root -g root  -I interface,ifTable,ifXTable,cpu,cpu_linux,hw_mem,extend,versioninfo,snmp_mib,ip,at,system_mib -p /run/snmpd.pid

status=$?

if [ $status -ne 0 ]; then
  echo "Failed to start snmpd: $status"
  exit $status
fi
