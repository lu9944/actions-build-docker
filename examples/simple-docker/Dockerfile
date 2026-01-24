# set the base image to Node.js
# https://hub.docker.com/_/node/
FROM node:22-slim

# install pm2 globally
RUN npm install -g pm2

RUN echo latest > ~/TEST_VERSION

# confirm installation
RUN node -v
RUN npm -v