#!/bin/bash

while true; do

    # CPU utilization = (total non-idle CPU time / total CPU time) * 100

    read cpu user nice system idle iowait irq softirq steal guest guest_nice < /proc/stat

    sleep 1

    read cpu2 user2 nice2 system2 idle2 iowait2 irq2 softirq2 steal2 guest2 guest_nice2 < /proc/stat

    prev_idle_cpu_time=$((idle+iowait))
    prev_non_idle=$((user+nice+system+irq+softirq+steal+guest+guest_nice))
    prev_total_cpu_time=$((prev_idle_cpu_time+prev_non_idle))

    idle_cpu_time=$((idle2+iowait2))
    non_idle=$((user2+nice2+system2+irq2+softirq2+steal2+guest2+guest_nice2))
    total_cpu_time=$((idle_cpu_time+non_idle))

    diff_non_idle=$((non_idle-prev_non_idle))
    diff_total_cpu_time=$((total_cpu_time-prev_total_cpu_time))
    cpu_usage=$(((1000*(diff_non_idle)/diff_total_cpu_time+5)/10)) # *1000 => to increase the precision: one decimal point of precision ; +5 => to round UP
    echo -en "\rCPU: $cpu_usage%  \b\b"
done
