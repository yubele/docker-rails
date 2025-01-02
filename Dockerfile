FROM node:23.2.0-bookworm-slim

ARG RAILS_ENV

ENV LANG "C.UTF-8"
ENV NOKOGIRI_USE_SYSTEM_LIBRARIES "YES"
ENV TZ "UTC"
ENV RUBY_VERSION="3.4.1"
ENV RUBY_SHA256="3d385e5d22d368b064c817a13ed8e3cc3f71a7705d7ed1bae78013c33aa7c87f"
ENV BUNDLER_VERSION="2.5.17"

ENV RAILS_ENV=$RAILS_ENV
ENV RAILS_SERVE_STATIC_FILES "1"
ENV PUPPETEER_SKIP_CHROMIUM_DOWNLOAD=true

SHELL ["/bin/bash", "-l", "-c"]

RUN apt-get update
RUN apt-get install --no-install-recommends -y gnupg2 gnupg1 gnupg
RUN apt-get install --no-install-recommends -y openjdk-17-jdk graphicsmagick graphviz
RUN apt-get install --no-install-recommends -y tzdata
RUN apt-get install --no-install-recommends -y nginx python3 unzip
RUN apt-get install --no-install-recommends -y imagemagick file
RUN apt-get install --no-install-recommends -y curl procps
RUN apt-get update
RUN apt-get install --no-install-recommends -y libyaml-dev libmagickwand-dev libmecab-dev libxslt-dev libmagic-dev libssl-dev libmariadb-dev
RUN apt-get install --no-install-recommends -y ffmpeg
RUN apt-get install -y build-essential

RUN apt-get install -y fonts-noto-cjk

WORKDIR "/tmp"
RUN MINOR=$(echo ${RUBY_VERSION} | sed -e 's/^\([0-9]\+\.[0-9]\+\)\..*$/\1/' ) && curl https://cache.ruby-lang.org/pub/ruby/$MINOR/ruby-${RUBY_VERSION}.tar.gz -o ruby.tar.gz \
  && [ $(sha256sum ruby.tar.gz | awk '{print $1}') = "${RUBY_SHA256}" ]
RUN tar zxf ruby.tar.gz -C .
RUN cd ruby-${RUBY_VERSION} && ./configure && make && make install
RUN gem update --system
RUN gem install bundler -v ${BUNDLER_VERSION}

RUN gem install foreman

RUN apt-get upgrade -y
ENTRYPOINT [ "/bin/bash", "-lc" ]
CMD [ "/app/entrypoint.sh" ]
