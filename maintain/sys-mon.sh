#!/bin/bash
set -o nounset -o pipefail; shopt -s nullglob
threshold=80
partition="/dev/sda2"

#ascii colors for terminal output
reset="\033[0m"
red="\033[31m"
green="\033[32m"
blue="\033[34m"


while true; do
    echo -e  "${green}Current time: $(date '+%Y-%m-%d %H:%M:%S')"
    echo -e "${blue}System uptime: $(uptime)"
    echo -e "${red}Free disk space: $(df -h / | awk 'NR==2 {print $4}')"
    usage=$(df -h | grep "$partition" | awk '{print $5}' | sed 's/%//')
    if [[ "$usage" -gt "$threshold" ]]; then
        echo "Disk usage on $partition is above $threshold%"
    fi
    #check network connectivity by pinging google dnc server
    if ping -c 1 8.8.8.8 >/dev/null; then
        echo "Network connection is up."
    else
        echo "Network connection is down."
    fi
    
    echo -e "${reset}"

    ## check if any process is using too much of CPU or memory
    if [[ $(ps -eo pid,%cpu,%mem,cmd | sort -k 3 -r | head -n 5 | grep -v PID) ]]; then
        echo "Top CPU and memory consuming processes:"
        ps -eo pid,%cpu,%mem,cmd |sort -k 3 -r | head -n 5 | grep -v PID 
    fi

    echo "-----------------------------------------------------"
    sleep 5
done
