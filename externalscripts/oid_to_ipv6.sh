#!/bin/bash
# DEPENDENCY sipcalc
declare -a data=($(echo $1 | tr '.' ' '))

ipv6=$(printf "%02x" "${data[@]}" | sed 's/.\{4\}/&:/g' | cut -d':' -f-8)

sipcalc $ipv6 | grep "Compressed address" | cut -d' ' -f3 

exit 0

