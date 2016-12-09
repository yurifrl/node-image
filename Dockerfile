# Use NodeJS Image
FROM node:4.0.0

# Define User
ENV USER root

# Set the ember enviroment
ENV EMBER_ENV production

# Update
RUN echo "deb http://us.archive.ubuntu.com/ubuntu/ precise-updates main restricted" | tee -a /etc/apt/sources.list.d/precise-updates.list
RUN apt-get update -qq
RUN apt-get install -y python2.7-dev

# Install dev dependencies
RUN npm install -g phantomjs
RUN npm install -g gulp

# install watchman
RUN \
  git clone https://github.com/facebook/watchman.git &&\
  cd watchman &&\
  git checkout v3.7.0 &&\
  ./autogen.sh &&\
  ./configure &&\
  make &&\
  make install

# Note: npm is v2.7.6
RUN npm install -g ember-cli@2.7.0 --allo-root
RUN npm install -g bower

EXPOSE 4200 49152

COPY runner /bin/runner

ENTRYPOINT ["/bin/runner"]

