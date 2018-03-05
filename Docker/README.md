# Docker Usage

You will need to build the image, so go into this directory in a shell and run: 
```bash 
docker build -t plexbot:latest .
```

Then create the configuration directory and start the container:

```bash
mkdir -p /opt/docker/config/plexbot
docker run -d --name plexbot -v /opt/docker/config/plexbot:/config -v /etc/localtime:/etc/localtime:ro plexbot:latest
```

It will fail the first time you run it (intentionally) because you need to fill out your settings.rb file, located in /opt/docker/config/plexbot.

You can use the following command to view the logs in stdout:

```bash
docker logs -f plexbot
```

(Don't use -f if you don't want to tail.)
