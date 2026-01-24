# set the base image to Debian
# https://hub.docker.com/_/debian/
FROM debian:latest

# replace shell with bash so we can source files
RUN rm /bin/sh && ln -s /bin/bash /bin/sh

# update the repository sources list
# and install dependencies
RUN apt-get update \
      && apt-get install -y --no-install-recommends curl wget \
      && apt-get -y autoclean \
      && rm -rf /var/lib/apt/lists/*

# nvm environment variables
ENV NVM_DIR=/root/.nvm
ENV NODE_VERSION=22.22.0

# install nvm
# https://github.com/creationix/nvm#install-script
RUN curl --silent -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.3/install.sh | bash

# install node, npm and pm2
RUN source $NVM_DIR/nvm.sh \
    && nvm install $NODE_VERSION \
    && nvm alias default $NODE_VERSION \
    && nvm use default \
    && npm install pm2

# add node and npm to path so the commands are available
ENV NODE_PATH=$NVM_DIR/versions/node/v$NODE_VERSION/lib/node_modules
ENV PATH=$NVM_DIR/versions/node/v$NODE_VERSION/bin:$PATH

RUN echo latest > ~/TEST_VERSION

# confirm installation
RUN node -v
RUN npm -v