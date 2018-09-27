#!/bin/bash
set -e

NCPU=$(cat /proc/cpuinfo | grep '^processor' | wc -l)

function stay_busy() {
	while true; do
		dd if=/dev/urandom of=/dev/null bs=1M count=1000000 status=none
	done
}

sudo sync

sudo sysctl -w kernel.softlockup_panic=1
sudo sysctl -w kernel.softlockup_all_cpu_backtrace=1
sudo sysctl -w kernel.watchdog_thresh=1

(cd hog && make clean)
(cd hog && make)

echo "starting background workers ..."
for cpu in $(seq $NCPU); do
	stay_busy &
done

echo "sleep 10 ..."
for i in $(seq 10 | tac); do
	echo $i
	sleep 1
done

uname -a >> log
sudo sync

echo "insmod ..."
sudo insmod hog.ko

echo "rmmod ..."
sudo rmmod hog.ko

echo "kill & wait ..."
kill $(jobs -p)
wait
