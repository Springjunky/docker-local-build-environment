#!/bin/bash
if [ $# -lt 1 ] ; then
  echo "Need your external interface as one parameter"
  echo "Common names are eth0, enp...,"
  echo "List of your names"
  ifconfig -a | sed 's/[ \t].*//;/^\(lo\|\)$/d'
  exit
fi

PORTS_TO_BLOCK="80,5555,2222"
EXTERNAL_INTERFACE=$1

# Flush and delete custom Chains
iptables -F DOCKER-USER
iptables -F EXTERNAL-ACCESS-DENY
iptables -X EXTERNAL-ACCESS-DENY

# Create a  log-and-drop Chain
iptables -N EXTERNAL-ACCESS-DENY
iptables -A EXTERNAL-ACCESS-DENY -j LOG --log-prefix "DCKR-EXT-ACCESS-DENY:" --log-level 6
iptables -A EXTERNAL-ACCESS-DENY -j DROP

# Block all incomming traffic for docker 
iptables -A DOCKER-USER -i $EXTERNAL_INTERFACE \
         -p tcp --match multiport \
         --dports $PORTS_TO_BLOCK \
         -j EXTERNAL-ACCESS-DENY 

# Restore default rule to return all the rest back to the FORWARD-Chain
iptables -A DOCKER-USER -j RETURN

echo "Rules created "
iptables -v -L DOCKER-USER
iptables -v -L EXTERNAL-ACCESS-DENY
echo "See logs with prefix DCKR-EXT-ACCESS-DENY:"