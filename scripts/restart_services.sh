#!/bin/bash
echo 
for i in couchpotatoserver plexpy sabnzbd sonarr; do 
  systemctl restart $i &
done
echo "All applications are restarting"
