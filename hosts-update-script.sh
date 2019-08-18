#!/usr/bin/env sh

# Description: Replaces the HOSTS file with a customized version. 
#
# This version are collected by StevenBlack/hosts project (https://github.com/StevenBlack/hosts)
# from different sources. Each version rejects a different type of domain, as: malware, fakenews, porn... 
#
# This script will replace the current hosts file for the selected one. 
# As it is explained below, if the cron job is set, this file will be updated automaticaly after every start-up.
# 
# The previous hosts files are backed as /etc/hosts_bk_{timestamp}. # TODO remove backup files older than X
#
# How to use it?
# - Download the script, ie:
#      /opt/hosts-update-script/hosts-update-script.sh
# - There are a list of 16 different combinations of hosts files, choose your one.
# - Search in the script code the variable 'SELECTED_HOSTS' and set your selected one. By default blocks by UNIFIED_HOSTS.
# - Make the script executable with: 
#      $ chmod 755 /opt/hosts-update-script/hosts-update-script.sh
# - Executing the scripts at Startup after 30 seconds:
#      $ sudo crontab -e
#   and add the line:
#      @reboot ( sleep 30 ; sh /opt/hosts-update-script/hosts-update-script.sh )

# TODO add --help option to the script and list all hosts versions option names
# TODO check if the version name parameter match, else list version options names.
# TODO get the selected option parameter, and proceed.
UNIFIED_HOSTS="https://raw.githubusercontent.com/StevenBlack/hosts/master/hosts"
UNIFIED_FAKENEWS_HOSTS="https://raw.githubusercontent.com/StevenBlack/hosts/master/alternates/fakenews/hosts"
UNIFIED_GAMBLING_HOSTS="https://raw.githubusercontent.com/StevenBlack/hosts/master/alternates/gambling/hosts"
UNIFIED_PORN_HOSTS="https://raw.githubusercontent.com/StevenBlack/hosts/master/alternates/porn/hosts"
UNIFIED_SOCIAL_HOSTS="https://raw.githubusercontent.com/StevenBlack/hosts/master/alternates/social/hosts"
UNIFIED_FAKENEWS_GAMBLING_HOSTS="https://raw.githubusercontent.com/StevenBlack/hosts/master/alternates/fakenews-gambling/hosts"
UNIFIED_FAKENEWS_PORN_HOSTS="https://raw.githubusercontent.com/StevenBlack/hosts/master/alternates/fakenews-porn/hosts"
UNIFIED_FAKENEWS_SOCIAL_HOSTS="https://raw.githubusercontent.com/StevenBlack/hosts/master/alternates/fakenews-social/hosts"
UNIFIED_GAMBLING_PORN_HOSTS="https://raw.githubusercontent.com/StevenBlack/hosts/master/alternates/gambling-porn/hosts"
UNIFIED_GAMBLING_SOCIAL_HOSTS="https://raw.githubusercontent.com/StevenBlack/hosts/master/alternates/gambling-social/hosts"
UNIFIED_PORN_SOCIAL_HOSTS="https://raw.githubusercontent.com/StevenBlack/hosts/master/alternates/porn-social/hosts"
UNIFIED_FAKENEWS_GAMBLING_PORN_HOSTS="https://raw.githubusercontent.com/StevenBlack/hosts/master/alternates/fakenews-gambling-porn/hosts"
UNIFIED_FAKENEWS_GAMBLING_SOCIAL_HOSTS="https://raw.githubusercontent.com/StevenBlack/hosts/master/alternates/fakenews-gambling-social/hosts"
UNIFIED_FAKENEWS_PORN_SOCIAL_HOSTS="https://raw.githubusercontent.com/StevenBlack/hosts/master/alternates/fakenews-porn-social/hosts"
UNIFIED_GAMBLING_PORN_SOCIAL_HOSTS="https://raw.githubusercontent.com/StevenBlack/hosts/master/alternates/gambling-porn-social/hosts"
UNIFIED_FAKENEWS_GAMBLING_PORN_SOCIAL_HOSTS="https://raw.githubusercontent.com/StevenBlack/hosts/master/alternates/fakenews-gambling-porn-social/hosts"

# Select here the hosts file to apply
SELECTED_HOSTS=$UNIFIED_HOSTS
# TODO get the selected option from the paramater

HOSTS_PATH="/etc/hosts"
TIMESTAMP_SUFFIX=$(date +'_%Y%m%d-%H%M%S-%N')
NEW_HOSTS_PREFIX="hosts_"
TEMP_FOLDER="/tmp/hosts-update-script/"
NEW_HOSTS=$TEMP_FOLDER$NEW_HOSTS_PREFIX$TIMESTAMP_SUFFIX

# Check for root
if [ "$(id -u)" -ne "0" ]; then
    echo "This script must be run as root" 1>&2
    exit 1
fi

# Create folder for temporary downloaded hosts file
mkdir -pv $TEMP_FOLDER

# Grab hosts file
wget -O $NEW_HOSTS $SELECTED_HOSTS

# Get the number of entries in the just downloaded HOSTS file
NEW_HOST_NUMBER_OF_ENTRIES=$(wc -l $NEW_HOSTS | cut -d " " -f 1)

# If the download hosts file has very little number of entries, it is ignored
ENTRIES_NUMBER_THRESHOLD=40000
if [ $NEW_HOST_NUMBER_OF_ENTRIES -lt $ENTRIES_NUMBER_THRESHOLD ]
then
   echo "INFO: hosts file is not updated, because it has a small number of entries: "$NEW_HOST_NUMBER_OF_ENTRIES", it should be bigger than "$ENTRIES_NUMBER_THRESHOLD

   # Clean up old downloads
   rm -v $TEMP_FOLDER$NEW_HOSTS_PREFIX*

   exit 1
fi

# Get the number of entries in the current HOSTS file
CURRENT_HOST_NUMBER_OF_ENTRIES=$(wc -l $HOSTS_PATH | cut -d " " -f 1)

# If the number of entries in new HOSTS are equal to the current one, skip the update
if [ $CURRENT_HOST_NUMBER_OF_ENTRIES -eq $NEW_HOST_NUMBER_OF_ENTRIES ]
then
   echo "INFO: hosts file is not updated, because the new hosts file has the same number of entries: "$CURRENT_HOST_NUMBER_OF_ENTRIES

   # Clean up old downloads
   rm -v $TEMP_FOLDER$NEW_HOSTS_PREFIX*

   exit 1
fi

# Backup old hosts file
cp -v $HOSTS_PATH ${HOSTS_PATH}.bk$TIMESTAMP_SUFFIX

# Set the new hosts file
cp -v $NEW_HOSTS $HOSTS_PATH

# Clean up old downloads
rm -v $TEMP_FOLDER$NEW_HOSTS_PREFIX*
