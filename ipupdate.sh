#!/bin/sh
 
# set some variables
zone=lek.iegget.no
dnsserver=ns1.iegget.no
keyfile=/home/iver/scripts/key.lek.iegget.no
#
 
# get current external address
ext_ip=`dig +short @resolver1.opendns.com myip.opendns.com`
 
# get last ip address from the DNS server
last_ip=`dig +short @$dnsserver $zone`
 
if [ ! -z "$ext_ip" ]; then
   if [ ! -z "$last_ip" ]; then
      if [ "$ext_ip" != "$last_ip" ]; then
         echo "IP addresses do not match (external=$ext_ip, last=$last_ip), sending an update"
 
         echo "server $dnsserver
         zone $zone.
         update delete $zone.
         update add $zone. 60 A $ext_ip
         update add $zone. 60 TXT 'Updated on $(date)'
         send" > /tmp/ipupdate.tmp
         nsupdate -k $keyfile -v /tmp/ipupdate.tmp
          
      else
         echo "success: IP addresses match (external=$ext_ip, last=$last_ip), nothing to do"
      fi
   else
      echo "fail: couldn't resolve last ip address from $dnsserver"
   fi
else
   echo "fail: couldn't resolve current external ip address from resolver1.opendns.com"
fi
