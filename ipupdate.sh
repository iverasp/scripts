#!/bin/sh

# Needs dnsutils in debian

# Generate key with
# dnssec-keygen -a HMAC-MD5 -b 512 -n HOST <name>

# set some variables
zone=home.iegget.no
dnsserver=129.241.105.205
keyfile=home.key
ipv6_enabled=true
initial_run=false

# get current external address
ext_ipv4=`dig +short A @resolver1.opendns.com myip.opendns.com`
ext_ipv6=`curl --silent https://ipv6.icanhazip.com/`
 
# get last ip address from the DNS server
last_ipv4=`dig +short A @$dnsserver $zone`
last_ipv6=`dig +short AAAA @$dnsserver $zone`
if [ "$initial_run" = true ]; then
    last_ipv4="none"
    last_ipv6="none"
fi

if [ ! -z "$ext_ipv4" ]; then
    if [ ! -z "$last_ipv4" ]; then
        if [ "$ext_ipv4" != "$last_ipv4" ]; then
            echo "IPv4 addresses do not match (external=$ext_ipv4, last=$last_ipv4), sending an update"
 
            echo "server $dnsserver
            zone $zone.
            update delete $zone. A
            update delete $zone. TXT
            update add $zone. 60 A $ext_ipv4 
            update add $zone. 60 TXT 'Updated on $(date)'
            send" > /tmp/ipupdate.tmp
            nsupdate -k $keyfile -v /tmp/ipupdate.tmp
          
        else
            echo "success: IPv4 addresses match (external=$ext_ipv4, last=$last_ipv4), nothing to do"
        fi
    else
        echo "fail: couldn't resolve last IPv4 address from $dnsserver"
    fi
else
    echo "fail: couldn't resolve current external IPv4 address from resolver1.opendns.com"
fi

if [ "$ipv6_enabled" = true ]; then
    if [ ! -z "$ext_ipv6" ]; then
        if [ ! -z "$last_ipv6" ]; then
            if [ "$ext_ipv6" != "$last_ipv6" ]; then
                echo "IPv6 addresses do not match (external=$ext_ipv6, last=$last_ipv6), sending an update"
 
                echo "server $dnsserver
                zone $zone.
                update delete $zone. AAAA
                update delete $zone. TXT
                update add $zone. 60 AAAA $ext_ipv6
                update add $zone. 60 TXT 'Updated on $(date)'
                send" > /tmp/ipupdate.tmp
                nsupdate -k $keyfile -v /tmp/ipupdate.tmp
          
            else
                echo "success: IPv6 addresses match (external=$ext_ipv6, last=$last_ipv6), nothing to do"
            fi
        else
            echo "fail: couldn't resolve last IPv6 address from $dnsserver"
        fi
    else
        echo "fail: couldn't resolve current external IPv6 address from ipv6.icanhazip.com"
    fi
fi
