FROM elixir:1.4.2

ENV NODE_VERSION=7

# Install system dependencies and nodejs, then clean up apt temporary artefacts
RUN apt-get -y update \
    && apt-get -y install apt-transport-https build-essential curl git make locales locales-all inotify-tools \
    && curl -sL https://deb.nodesource.com/setup_$NODE_VERSION.x | bash - \
    && apt-get -y install nodejs \
    && apt-get -y clean \
    && rm -rf /var/cache/apt/*

# Elixir requires UTF-8
RUN locale-gen en_US.UTF-8
ENV LANG en_US.UTF-8
ENV LC_ALL en_US.UTF-8
ENV LANGUAGE en_US:en

# Install Hex and Rebar
RUN mix local.hex --force \
    && mix local.rebar --force

RUN mkdir /myapp
WORKDIR /myapp

ADD mix.* /myapp/
RUN mix deps.get
RUN mix deps.compile

ADD package.json /myapp/
RUN npm install

ADD . /myapp/
RUN mix compile

CMD iex
