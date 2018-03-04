FROM lsiobase/alpine:3.7

# set version label
ARG BUILD_DATE
ARG VERSION

RUN \
 echo "**** install packages ****" && \
 apk add --no-cache \
	ca-certificates \
	curl \
	tar \
	unrar \
	unzip \
	wget \
  git \
  ruby \
  ruby-rdoc \
  ruby-bigdecimal \
  ruby-irb

RUN \
  echo "**** clone repository ****" && \
  git clone https://github.com/AndrewPaglusch/PlexBot.git /plexbot

RUN \
  echo "**** Installing gem ****" && \
  gem install telegram-bot-ruby

COPY entrypoint.sh /

CMD ["/entrypoint.sh"]


