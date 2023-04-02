#!/bin/bash

# This script computes the CPU usage of the system.

# It is based on the following formula:
# CPU utilization = (total non-idle CPU time / total CPU time) * 100
# where:
# total non-idle CPU time = user + nice + system + irq + softirq + steal + guest + guest_nice
# total CPU time = total non-idle CPU time + idle + iowait

# date format for the log file
date_format="date +\"%a %d %b %Y %r\"" 
script_path=$(realpath $0)
error_msg_format="$(eval ${date_format}) --- ${script_path} --- Error ---"

CPU_DURATION_THRESHOLD=$(grep "CPU_DURATION_THRESHOLD" project-config.yml | awk '{print $2}' | tr -d ' ')

# Read the first line of /proc/stat
read cpu user nice system idle iowait irq softirq steal guest guest_nice < /proc/stat; read_exit_status=$?
if [ $read_exit_status -ne 0 ]; then
    echo "${error_msg_format} Could not read /proc/stat" >&2
    exit 1
fi

# Sleep for CPU_DURATION_THRESHOLD second(s)
sleep ${CPU_DURATION_THRESHOLD}; read_exit_status=$?
if [ $read_exit_status -ne 0 ]; then
    echo "${error_msg_format} Could not sleep" >&2
    exit 1
fi

# Read the first line of /proc/stat again
read cpu2 user2 nice2 system2 idle2 iowait2 irq2 softirq2 steal2 guest2 guest_nice2 < /proc/stat; read_exit_status=$?
if [ $read_exit_status -ne 0 ]; then
    echo "${error_msg_format} Could not read /proc/stat" >&2
    exit 1
fi

# Calculate CPU usage
prev_idle_cpu_time=$((idle+iowait))
prev_non_idle=$((user+nice+system+irq+softirq+steal+guest+guest_nice))
prev_total_cpu_time=$((prev_idle_cpu_time+prev_non_idle))

idle_cpu_time=$((idle2+iowait2))
non_idle=$((user2+nice2+system2+irq2+softirq2+steal2+guest2+guest_nice2))
total_cpu_time=$((idle_cpu_time+non_idle))

diff_non_idle=$((non_idle-prev_non_idle))
diff_total_cpu_time=$((total_cpu_time-prev_total_cpu_time))

cpu_usage=$(((1000*(diff_non_idle)/diff_total_cpu_time+5)/10)); exit_status=$? # *1000 => to increase the precision: one decimal point of precision ; +5 => to round UP
if [ $exit_status -ne 0 ]; then
    echo "${error_msg_format} Could not calculate cpu_usage" >&2
    exit 1
elif [ $cpu_usage -gt 100 ]; then
    echo "${error_msg_format} cpu_usage > 100%" >&2
    exit 1
elif [ $cpu_usage -lt 0 ]; then
    echo "${error_msg_format} cpu_usage < 0%" >&2
    exit 1
fi

echo "$cpu_usage"