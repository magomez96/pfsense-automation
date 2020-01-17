#!/bin/sh
# in my setup, igb2 is the Tier-2 gateway. The Tier-1 gateway is igb0.
# This script would be most likely be used with a data-capped Tier-2
# WAN connection. This script will check for states on the Tier-2 gateway
# while the Tier-1 gateway is active, and if any exist it will remove them. 

WAN_CHECK_INTERVAL=${1:-60}
PRI_WAN="igb0"
BACK_WAN="igb2"

while true; do
sleep "$WAN_CHECK_INTERVAL"
	CURRENT_GW="$(netstat -rn4 | awk '/default/{print $4}')"
	if [ "$CURRENT_GW" = $PRI_WAN ]; then
		WAN2_STATES="$(pfctl -i $BACK_WAN -s states | grep -v NO_TRAFFIC)"
		if [ -n "$WAN2_STATES" ]; then
			/etc/rc.kill_states $BACK_WAN
		fi
	fi
done
