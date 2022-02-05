FROM lsiobase/alpine:3.11

# set version label
ARG BUILD_DATE
ARG VERSION

ENV PLEXBOT_VERSION master

RUN \
 echo "**** install packages ****" && \
 apk add --no-cache \
	ca-certificates \
	curl \
	tar \
	unzip \
	wget \
  git \
  ruby \
  ruby-rdoc \
  ruby-bigdecimal \
  ruby-irb

RUN \
  echo "**** clone repository ****" && \
  git clone -b ${PLEXBOT_VERSION} https://github.com/AndrewPaglusch/PlexBot.git /plexbot

RUN \
  echo "**** Installing gem ****" && \
  gem install telegram-bot-ruby

COPY entrypoint.sh /

CMD ["/entrypoint.sh"]


