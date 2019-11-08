#!/bin/bash

if [[ $1 == "test-connected" ]]; then
	[[ `bluetoothctl show | grep "Powered: yes" | wc -l` -gt 0 && `bluetoothctl info | grep "Connected: yes" | wc -l` -gt 0 ]] && exit 0 || exit 1
else
	bluetoothctl info | grep "Alias: " | cut -d":" -f2- | cut -c2-
fi
