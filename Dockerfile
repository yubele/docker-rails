FROM debian:bookworm-20240701-slim

ARG RAILS_ENV

ENV LANG "C.UTF-8"
ENV NOKOGIRI_USE_SYSTEM_LIBRARIES "YES"
ENV TZ "UTC"
ENV NODE_VERSION="20.15.0"
ENV NPM_VERSION="10.8.1"
ENV RUBY_VERSION="3.4.0-preview1"
ENV BUNDLER_VERSION="2.5.14"
ENV RUBY_SHA256="83c05b2177ee9c335b631b29b8c077b4770166d02fa527f3a9f6a40d13f3cce2"

ENV RAILS_ENV=$RAILS_ENV
ENV RAILS_SERVE_STATIC_FILES "1"
ENV PUPPETEER_SKIP_CHROMIUM_DOWNLOAD=true

SHELL ["/bin/bash", "-l", "-c"]

RUN apt-get update
RUN apt-get install --no-install-recommends -y gnupg2 gnupg1 gnupg
RUN apt-get install --no-install-recommends -y openjdk-17-jdk graphicsmagick graphviz
RUN apt-get install --no-install-recommends -y mecab-ipadic mecab-ipadic-utf8 mecab-utils
RUN apt-get install --no-install-recommends -y tzdata
RUN apt-get install --no-install-recommends -y nginx python3 unzip
RUN apt-get install --no-install-recommends -y imagemagick file
RUN apt-get install --no-install-recommends -y curl procps
RUN apt-get update
RUN apt-get install --no-install-recommends -y libyaml-dev libmagickwand-dev libmecab-dev libxslt-dev libmagic-dev libssl-dev libmariadb-dev
RUN apt-get install --no-install-recommends -y ffmpeg
RUN apt-get install -y build-essential

# Security Updates
RUN apt-get remove -y nodejs libnss3

RUN mkdir /noto
ADD https://noto-website.storage.googleapis.com/pkgs/NotoSansCJKjp-hinted.zip /noto
WORKDIR /noto
RUN unzip NotoSansCJKjp-hinted.zip && \
    mkdir -p /usr/share/fonts/noto && \
    cp *.otf /usr/share/fonts/noto && \
    chmod 644 -R /usr/share/fonts/noto/
RUN rm -rf /noto

WORKDIR "/tmp"
RUN MINOR=$(echo ${RUBY_VERSION} | sed -e 's/^\([0-9]\+\.[0-9]\+\)\..*$/\1/' ) curl https://cache.ruby-lang.org/pub/ruby/$MINOR/ruby-${RUBY_VERSION}.tar.gz -o ruby.tar.gz \
  && [ $(sha256sum ruby.tar.gz | awk '{print $1}') = "${RUBY_SHA256}" ]
RUN tar zxf ruby.tar.gz -C .
RUN cd ruby-${RUBY_VERSION} && ./configure && make && make install
RUN gem update --system
RUN gem install bundler -v ${BUNDLER_VERSION}

RUN curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | apt-key add -
RUN echo "deb https://dl.yarnpkg.com/debian/ stable main" | tee /etc/apt/sources.list.d/yarn.list
RUN curl -fsSL https://fnm.vercel.app/install | bash && . /root/.bashrc && fnm use --install-if-missing ${NODE_VERSION}
RUN . /root/.bashrc && npm install -g npm@${NPM_VERSION}
RUN . /root/.bashrc && npm install --global yarn

RUN gem install foreman

RUN apt-get update
RUN apt-get install --no-install-recommends -y chromium

RUN apt-get upgrade -y
CMD ["/bin/sh", "/app/entrypoint.sh"]
