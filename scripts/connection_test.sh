#!/bin/bash
echo 
echo "Availability Test of All Services"

#Test plex via local ip - #1
if $(curl -sN http://<YOUR_PLEX_SERVER_IP>:<YOUR_PLEX_SERVER_PORT>/web/index.html | grep -q 'return Object'); then 
	echo " - <YOUR_PLEX_SERVER_NAME> server is UP - Test #1"
else 
	echo " - <YOUR_PLEX_SERVER_NAME> server is **DOWN** - Test #1"
fi

#Test plex via local ip - #2
if curl --silent --fail http://<YOUR_PLEX_SERVER_IP>:<YOUR_PLEX_SERVER_PORT>/web/index.html 1>/dev/null; then 
	echo " - <YOUR_PLEX_SERVER_NAME> server is UP - Test #2"
else 
	echo " - <YOUR_PLEX_SERVER_NAME> server is **DOWN** - Test #2"
fi

#Test plex.tv
if $(curl -m5 -sN https://www.plex.tv | grep -q 'Plex Pass'); then
        echo " - www.plex.tv is UP"
else
        echo " - www.plex.tv is **DOWN**"
fi

#Test Sonarr
if $(curl -m5 -sN http://<YOUR_SONARR_IP>:<YOUR_SONARR_PORT> | grep -q 'page-container'); then
        echo " - Sonarr is UP"
else
        echo " - Sonarr is **DOWN**"
fi

#Test CouchPotato
if $(curl -m5 -sN http://<YOUR_CP_IP>:<YOUR_CP_PORT> | grep -q 'couchpotatoserver_config.ini'); then
        echo " - CouchPotato is UP"
else
        echo " - CouchPotato is **DOWN**"
fi

#Test SabNZBd
if $(curl -m5 -sN http://<YOUR_SABNZBD_IP>:<YOUR_SABNZBD_PORT> | grep -q 'The automatic usenet download tool'); then
        echo " - SabNZBd is UP"
else
        echo " - SabNZBd is **DOWN**"
fi

#Test PlexPy
if $(curl -m5 -sN http://<YOUR_PLEXPY_IP>:<YOUR_PLEXPY_PORT>/home | grep -q 'update the progress bars'); then
        echo " - PlexPy is UP"
else
        echo " - PlexPy is **DOWN**"
fi
