#!/bin/bash
echo 
echo "Plex Server Load:"
ssh root@<YOUR_PLEX_SERVER_IP> 'uptime' | egrep -o 'load.*'
