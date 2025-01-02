#!/bin/bash

from=$(cat Dockerfile | grep FROM | sed -s 's/FROM //' | sed -s 's/:/-/')
npm=$(cat Dockerfile | grep 'ENV NPM_VERSION' | sed -s 's/ENV NPM_VERSION=//' | sed -s 's/"//g' )
ruby=$(cat Dockerfile | grep 'ENV RUBY_VERSION' | sed -s 's/ENV RUBY_VERSION=//' | sed -s 's/"//g' )
bundler=$(cat Dockerfile | grep 'ENV BUNDLER_VERSION' | sed -s 's/ENV BUNDLER_VERSION=//' | sed -s 's/"//g' )

echo $from-node$node-ruby$ruby-bundler$bundler
