#!/bin/bash

echo ""
echo "List of users currently streaming Plex:"
curl -is http://<YOUR_PLEX_SERVER_IP>:<YOUR_PLEX_SERVER_PORT>/status/sessions?X-Plex-Token=<PLEX_API_TOKEN> | grep 'User id' | awk -F '"' '{print $6}'
