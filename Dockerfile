FROM debian:bullseye-slim

ARG RAILS_ENV

ENV LANG "C.UTF-8"
ENV NOKOGIRI_USE_SYSTEM_LIBRARIES "YES"
ENV TZ "UTC"
ENV NODE_VERSION="18.12.1"
ENV NPM_VERSION="9.7.2"
ENV RUBY_VERSION="3.2.2"
ENV BUNDLER_VERSION="2.4.13"
ENV RUBY_SHA256="96c57558871a6748de5bc9f274e93f4b5aad06cd8f37befa0e8d94e7b8a423bc"

ENV RAILS_ENV=$RAILS_ENV
ENV RAILS_SERVE_STATIC_FILES "1"
ENV PUPPETEER_SKIP_CHROMIUM_DOWNLOAD=true

RUN apt-get update
RUN apt-get install --no-install-recommends -y gnupg2 gnupg1 gnupg
RUN apt-get install --no-install-recommends -y openjdk-11-jdk graphicsmagick graphviz
RUN apt-get install --no-install-recommends -y mecab-ipadic mecab-ipadic-utf8 mecab-utils
RUN apt-get install --no-install-recommends -y tzdata git
RUN apt-get install --no-install-recommends -y nginx python2 unzip
RUN apt-get install --no-install-recommends -y chromium imagemagick file
RUN apt-get install --no-install-recommends -y curl procps
RUN apt-get install --no-install-recommends -y libyaml-dev libmagickwand-dev libmecab-dev libxslt-dev libmagic-dev libssl-dev libmariadb-dev

RUN apt-get install -y build-essential

RUN mkdir /noto
ADD https://noto-website.storage.googleapis.com/pkgs/NotoSansCJKjp-hinted.zip /noto
WORKDIR /noto
RUN unzip NotoSansCJKjp-hinted.zip && \
    mkdir -p /usr/share/fonts/noto && \
    cp *.otf /usr/share/fonts/noto && \
    chmod 644 -R /usr/share/fonts/noto/
RUN rm -rf /noto

WORKDIR "/tmp"
RUN curl https://cache.ruby-lang.org/pub/ruby/3.2/ruby-${RUBY_VERSION}.tar.gz -o ruby.tar.gz \
  && [ $(sha256sum ruby.tar.gz | awk '{print $1}') = "${RUBY_SHA256}" ]
RUN tar zxf ruby.tar.gz -C .
RUN cd ruby-${RUBY_VERSION} && ./configure && make && make install
RUN gem update --system
RUN gem install bundler -v ${BUNDLER_VERSION}

RUN curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | apt-key add -
RUN echo "deb https://dl.yarnpkg.com/debian/ stable main" | tee /etc/apt/sources.list.d/yarn.list
RUN apt-get update
RUN apt-get install --no-install-recommends -y yarn npm
RUN npm install -g n
RUN npm install -g npm@${NPM_VERSION}
RUN n ${NODE_VERSION}

RUN gem install foreman
CMD ["/bin/sh", "/app/entrypoint.sh"]
