# PlexBot
Sonarr &amp; Couch Potato Self-Serve Via Telegram

PlexBot is a bot that will run in the background on a Linux server/computer and monitor a Telegram group for incoming download requests from other members of the group. It utilizes the Sonarr and Couch Potato APIs for the downloading of content.

Enables users of your Plex Media Server (or any other media server) to add new TV shows and movies themselves automatically without bothering you.

# Getting Started

Ensure you have [Sonarr](https://github.com/Sonarr/Sonarr) & [Couch Potato](https://github.com/CouchPotato/CouchPotatoServer) installed and running with API access enabled. They don't have to be on the same server as PlexBot. PlexBot just has to be able to reach their APIs.

Create a [Telegram](https://telegram.org/) account. A [Telegram group](https://telegram.org/faq#q-how-do-i-create-a-group). A [Telegram bot](https://core.telegram.org/bots#creating-a-new-bot). Add your bot to the Telegram group you just created.
Add your Plex users to the Telegram group so they can use the bot to request new content.

# Installation

## RHEL/CentOS 7.X

```
yum -y install ruby rubygems
gem install telegram-bot-ruby
mkdir -p /opt/<your_telegram_bot_name/
cd /opt/<your_telegram_bot_name/
git clone git@github.com:AndrewPaglusch/PlexBot.git
cp settings.rb-example settings.rb
cp scripts-example scripts
#edit your settings.rb file
#edit scripts in scripts directory
```

# Daemonize

## Make the Service

Create this file `/etc/systemd/system/<your_bot_name>.service`. 

Insert the following:

```[Unit]
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

## Enable & Start

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
