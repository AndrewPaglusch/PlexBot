#!/bin/bash
echo 
for i in couchpotatoserver plexbot plexpy sabnzbd sonarr; do 
  echo $i $(systemctl is-active $i) | sed 's|active|running|g'
done | column -t
