#!/bin/bash

# Cette commande prend trop de temps, créer d'abord le script de conf et le fichier de conf pour mettre si c'est une instance aws dedans pour ne pas vérifier ça à chaque exécution
curl -s http://169.254.169.254/latest/meta-data/instance-id >/dev/null 2>&1; system_is_aws_instance=$?
if [ ${system_is_aws_instance} -eq 0 ]; then
    # If the server is an AWS instance, CPU usage is calculated using the formula: CPU Utilization = 100 - idle_time - steal_time
    cpu_usage=$(top -bn 1 | grep "Cpu(s)" | awk '{print "100-"$8"-"$16}' | sed 's/,/./g' | bc)
else
    # CPU Utilization = 100 - idle_time 
    for((i=0;i<50;i++)); do
        cpu_usage=$(top -bn 1 | grep "Cpu(s)" | awk '{print "100-"$8}' | sed 's/,/./g' | bc)
        echo $cpu_usage
    done
fi
script_name=$(basename "$0")
ps | grep "${script_name}"

