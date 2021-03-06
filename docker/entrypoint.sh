#!/bin/bash
set +x

mkdir -p /config

if [ -d /config/static_messages ]; then
  if [ -L /plexbot/static_messages ]; then
    echo "Static messages is already a symlink."
    cp -ruv /plexbot/static_messages.git /config
  else 
    mv /plexbot/static_messages /plexbot/static_messages.git
    ln -s /config/static_messages /plexbot/static_messages
    cp -ruv /plexbot/static_messages.git /config
  fi
else
  cp -nrv /plexbot/static_messages /config
  mv /plexbot/static_messages /plexbot/static_messages.git
  ln -s /config/static_messages /plexbot/static_messages
fi

cp -nrv /plexbot/scripts-example/ /config/scripts

if [ -L /plexbot/settings.rb ]; then
  echo "settings.rb is already symlinked."
else
  ln -s /config/settings.rb /plexbot/settings.rb
fi  

if [ -L /plexbot/scripts ]; then
  echo "Scripts is already symlinked."
else
  ln -s /config/scripts /plexbot
fi

if [ -f /config/settings.rb ]; then
  cp -uv /plexbot/settings.rb-example /config/settings.rb-example
else
  cp -rv /plexbot/settings.rb-example /config/settings.rb
  echo "You need to edit your settings.rb file."
  exit 1
fi

cd /plexbot
ruby /plexbot/run.rb 
