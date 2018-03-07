# PlexBot
Sonarr &amp; Couch Potato Self-Serve Via Telegram

PlexBot is a bot that will run in the background on a Linux server/computer and monitor a Telegram group for incoming download requests from other members of the group. It utilizes the Sonarr and Couch Potato APIs for the downloading of content.

Enables users of your Plex Media Server (or any other media server) to add new TV shows and movies themselves automatically without bothering you.

# Getting Started

Ensure you have [Sonarr](https://github.com/Sonarr/Sonarr) & [Couch Potato](https://github.com/CouchPotato/CouchPotatoServer) installed and running with API access enabled. They don't have to be on the same server as PlexBot. PlexBot just has to be able to reach their APIs.

Create a [Telegram](https://telegram.org/) account. A [Telegram group](https://telegram.org/faq#q-how-do-i-create-a-group). A [Telegram bot](https://core.telegram.org/bots#creating-a-new-bot). Add your bot to the Telegram group you just created.
Add your Plex users to the Telegram group so they can use the bot to request new content.

# Installation

## With Docker or Docker Compose 

### Docker

```bash
mkdir -p /opt/docker/build
git clone https://github.com/AndrewPaglusch/PlexBot.git
cd PlexBot/docker
docker build -t local/plexbot:v0.2.0 # Replace version number with the current one.
docker create --name plexbot -v /opt/docker/config/plexbot:/config local/plexbot:v0.2.0
docker start plexbot
docker logs -f plexbot # This lets you view logs
```

### Docker Compose

Create a docker-compose.yml file with the following:

```yaml
    plexbot:
        build:
          context: /opt/docker/build/docker-plexbot
          dockerfile: Dockerfile
        container_name: plexbot
        volumes:
          - /opt/docker/config/plexbot:/config
          - /etc/localtime:/etc/localtime:ro
        env_file: uidgid.env
        restart: always
```

If you don't want to run plexbot as root, create a system account and assign uidgid.env the UID/GID of the system account:

```bash
PGID=995
PUID=997
```

You can then build the image and start it. 

```bash
cd /opt/docker
docker-compose build --no-cache plexbot
docker-compose up plexbot # use up -d to run it in daemonized mode instead of the foreground.
```


## Without Docker (System Installation)

### RHEL/CentOS 7.X

```bash
yum -y install ruby rubygems
gem install telegram-bot-ruby
mkdir -p /opt/<your_telegram_bot_name/
cd /opt/<your_telegram_bot_name/
git clone https://github.com/AndrewPaglusch/PlexBot.git
cp settings.rb-example settings.rb
cp scripts-example scripts
#edit your settings.rb file
#edit scripts in scripts directory
```

### Daemonize

#### Make the Service

Create this file `/etc/systemd/system/<your_bot_name>.service`. 

Insert the following:

```bash
[Unit]
Description=<your_bot_name> Telegram Bot
After=network.target

[Service]
WorkingDirectory=/opt/plexbot
Type=simple
ExecStart=/usr/bin/ruby /<install_location>/run.rb
Restart=always
RestartSec=15

[Install]
WantedBy=multi-user.target
```

### Enable & Start

```
systemctl enable <your_bot_name>.service
systemctl start <your_bot_name>.service
systemctl status <your_bot_name>.service
```

# Default Commands

## /help
Show supported PlexBot commands

## /movie OR /m <movie name>
Request that PlexBot search for and download a movie via Couch Potato

## /show OR /s <show name>
Request that PlexBot search for and download a show via Sonarr

## /admin OR /a <command>
Run an admin-only command. Admin UIDs are listed in the `settings.rb` file
