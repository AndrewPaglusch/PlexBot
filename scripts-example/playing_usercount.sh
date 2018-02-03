#!/bin/bash

echo ""
echo "Number of users currently streaming Plex:"
curl -is http://<YOUR_PLEX_SERVER_IP>:<YOUR_PLEX_SERVER_PORT>/status/sessions?X-Plex-Token=<PLEX_SERVER_TOKEN> | grep 'User id' | wc -l
