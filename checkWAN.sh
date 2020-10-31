#!/bin/sh
# In my setup, igb2 is the Tier-2 gateway. The Tier-1 gateway is igb0
WAN_CHECK_INTERVAL=${1:-60}
PRI_WAN="igb0"
BACK_WAN="igb2"
BACK_WAN_IP="$(/sbin/ifconfig $BACK_WAN | /usr/bin/awk '/inet /{print $2}')"

while true; do
sleep "$WAN_CHECK_INTERVAL"
	CURRENT_GW="$(/usr/bin/netstat -rn4 | /usr/bin/awk '/default/{print $4}')"
	if [ "$CURRENT_GW" = $PRI_WAN ]; then
        WAN2_STATES="$(/sbin/pfctl -i $BACK_WAN -s states | /usr/bin/grep -v NO_TRAFFIC)"
		if [ -n "$WAN2_STATES" ]; then
			/sbin/pfctl -k "$BACK_WAN_IP" > /dev/null
                fi
	fi
done
