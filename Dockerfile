FROM elixir:1.4.2

ENV NODE_VERSION=7

# Install system dependencies and nodejs, then clean up apt temporary artefacts
RUN curl -sL https://deb.nodesource.com/setup_$NODE_VERSION.x | bash - \
    && apt-get -y install nodejs inotify-tools \
    && apt-get -y clean \
    && rm -rf /var/cache/apt/*

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
