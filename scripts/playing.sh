#!/bin/bash

echo ""
echo "List of users currently streaming Plex:"
curl -is http://PLEX_IP_HERE:PLEX_PORT_HERE/status/sessions?X-Plex-Token=PLEX_TOKEN_HERE | grep 'User id' | awk -F '"' '{print $6}'
