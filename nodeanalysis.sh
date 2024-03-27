#!/bin/bash
### Set the duration/intervals in seconds (10 minutes = 20 * interval) and variables for hostname and core count
interval=30
DURATION=$((5 * interval))
TIMESTAMP=0
HOSTNAME=$(hostname)
NUM_CORES=$(grep -c '^processor' /proc/cpuinfo)
### Create CSV file to store data
CSV_FILE_OUTPUT="${HOSTNAME}_output.csv"
echo "Index, Time, temp.(°C), Load, PWR, $(printf 'C%d_Freq, ' $(seq 0 $((NUM_CORES - 1))))" > "$CSV_FILE_OUTPUT"
### Functions to get CPU Temp/Freq/Power/Load
get_temperature() {
    ### cat 'Sensors' file and convert to celsius 
    TEMP_INPUT="/sys/class/hwmon/hwmon1/temp1_input"
    TEMP=$(cat "$TEMP_INPUT")
    TEMP_C=$(echo "scale=2; $TEMP / 1000" | bc)
    echo "$TEMP_C"
}
get_load() {
        uptime | sed -n "s/^.*load average/load average/p" | sed -e "s/load average://g" | awk -F, '{print $1}'
}
get_power() {
        omreport chassis pwrmonitoring | grep -A 4 "Power Consumption" | grep Reading | awk '{print $3}'
}
get_frequency() {
    ### Get frequency of each CPU core
    while read -r line; do
        if [[ $line =~ ^cpu\ MHz ]]; then
            freq_mhz=$(echo "$line" | awk '{print $4}')
            echo -n "$freq_mhz,"
        fi
    done < /proc/cpuinfo
}
###Starts recording as background task
(
for ((i=0; i<5; i++))
do
    TIMESTAMP=$(date +"%Y-%m-%d %H:%M:%S")
    TEMPERATURE=$(get_temperature)
    LOAD=$(get_load)
    POWER=$(get_power)
    FREQUENCY=$(get_frequency)
    echo "$i, $TIMESTAMP, $TEMPERATURE, $LOAD, $POWER, $FREQUENCY" >> "$CSV_FILE_OUTPUT"
    sleep "$interval"
done
) &
### Start stress test (adjust io/hdd/timeout as needed for the test)
sleep 30
stress-ng --cpu "$(nproc)" --io 4 --hdd 1 --vm-bytes $(awk '/MemFree/{printf "%dn", $2 * 0.9;}' < /proc/meminfo)k --vm-keep -m 1 --timeout 60 &
wait
### Clean up stress test
killall nodeanalysis.sh

