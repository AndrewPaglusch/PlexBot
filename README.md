# PlexBot
Sonarr &amp; Couch Potato Self-Serve Via Telegram

PlexBot is a Telegram bot that runs in Docker and monitors a Telegram group for incoming download requests from other members of the group. It utilizes the Sonarr and Couch Potato APIs for downloading multimedia content.
PlexBot enables users of your streaming media server to add new TV shows and movies themselves automatically without bothering you.

# Getting Started

Ensure you have [Sonarr](https://github.com/Sonarr/Sonarr) & [Couch Potato](https://github.com/CouchPotato/CouchPotatoServer) installed and running with API access enabled. They don't have to be on the same server as PlexBot. PlexBot just has to be able to reach their APIs.

Create a [Telegram](https://telegram.org/) account. A [Telegram group](https://telegram.org/faq#q-how-do-i-create-a-group). A [Telegram bot](https://core.telegram.org/bots#creating-a-new-bot). Add your bot to the Telegram group you just created.
Add your Plex users to the Telegram group so they can use the bot to request new content.

# Installation With Docker Compose

Create a `docker-compose.yml` file

```
mkdir -p /opt/docker
touch /opt/docker/docker-compose.yml
```

Add the following to `docker-compose.yml`

```yaml
version: '2'
services:
    plexbot:
        image: 'andrewpaglusch/plexbot:latest'
        container_name: plexbot
        volumes:
          - /opt/docker/config/plexbot:/config:ro
          - /etc/localtime:/etc/localtime:ro
        environment:
          - 'PGID=989'
          - 'PUID=991'
          - 'TZ="America/Chicago"'
        restart: always
```

Start PlexBot & Watch The Logs

`docker-compose up -d ; docker-compose logs -f plexbot`

PlexBot will fail to start the first time around. Now, go and configure PlexBot in `/opt/docker/plexbot/config/settings.rb`. There are helpful comments in `settings.rb` to help you along.
Once you're finished, start PlexBot back up again.

```
docker-compose up -d
```

# Default PlexBot Commands

### `/help`
Show supported PlexBot commands

### `/movie` OR `/m <movie name>`
Request that PlexBot search for and download a movie via Couch Potato

### `/show` OR `/s <show name>`
Request that PlexBot search for and download a show via Sonarr

### `/admin` OR `/a <command>`
Run an admin-only command. Admin UIDs are listed in the `settings.rb` file
