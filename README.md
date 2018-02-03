# PlexBot
Sonarr &amp; Couch Potato Self-Serve Via Telegram

Enables users of your Plex Media Server (or any other media server) to add new TV shows and movies themselves automatically without bothering you.

# Getting Started

Ensure you have [Sonarr](https://github.com/Sonarr/Sonarr) & [Couch Potato](https://github.com/CouchPotato/CouchPotatoServer) installed and running with API access enabled
Create a [Telegram](https://telegram.org/) account. A [Telegram group](https://telegram.org/faq#q-how-do-i-create-a-group). A [Telegram bot](https://core.telegram.org/bots#creating-a-new-bot)
Add your Plex users to the telegram group so they can use this bot to request new content

# Installation

## RHEL/Fedora 7+

```
yum -y install ruby rubygems
gem install telegram-bot-ruby
mkdir -p /opt/<your_telegram_bot_name/
cd /opt/<your_telegram_bot_name/
git clone git@github.com:AndrewPaglusch/PlexBot.git
cp settings.rb-example settings.rb
#edit your settings.rb file
```

# Daemonize

## Make the Service

`/etc/systemd/system/<your_bot_name>.service`. Insert the following:

```[Unit]
Description=<your_bot_name> Telegram Bot
After=network.target

[Service]
#StandardOutput=journal
#StandardError=journal
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
