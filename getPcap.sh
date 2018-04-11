#!/bin/bash

display_usage() {
        echo -e '\n\nUSAGE: getPcap IP "DD MMM YYYY" "HH:MM" "HH:MM"'
        echo -e 'getPcap 1.1.1.1 "09 Sep 2015" "01:12" "20:00"\n\n'
}

# if three arguments not supplied, display usage
if [ $# -ne 4 ]; then
        display_usage
        exit 1
fi

# check whether user had supplied -h or --help . If yes display usage
if [[ ($# == "--help") || ($# == "-h") ]]; then
        display_usage
        exit 0
fi

# Set the prompt for the select command
PS3="Choose interface or 'q' to quit: "
echo -e "\n\n"

# Create a list of directories to display
dirList=$(find /nsm/sensor_data/ -maxdepth 1 -mindepth 1 -type d | sort)

# Show a menu and ask for input.
select dir in $dirList; do
    if [ -n "$dir" ]; then
        int=$dir
    else
                exit
    fi
    break
done

pdate=`date -d "$2" +%Y-%m-%d`

cd $int/dailylogs/$pdate
rm /tmp/merged.pcap 2> /dev/null

# find all files created between the times of $2 and $3
find . -newerct "$2 $3" ! -newerct "$2 $4" | xargs -I {} tcpdump -r {} -w /tmp/{} host $1
# merge all pcaps
mergecap -w /tmp/merged.pcap /tmp/snort* 2> /dev/null
# remove all pcaps used to created the merged pcap
rm /tmp/snort.log* 2> /dev/null
if [ ! -f /tmp/merged.pcap ]; then
  echo -e "No data was found in sensor data that matched the input parameters"
else
  echo -e "\n\n*********************************************************************************************"
  echo -e "Merged PCAP is /tmp/merged.pcap"
  ls -l /tmp/merged.pcap
  echo -e "*********************************************************************************************\n\n"
fi
