#!/bin/bash
echo 
echo "Plex Media Server Status:"
ssh root@<YOUR_PLEX_SERVER_IP> 'systemctl status plexmediaserver' | grep 'Active'
