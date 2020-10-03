FROM ruby:2.7.1-alpine3.12

RUN apk update && apk upgrade
RUN apk add bash
RUN apk add curl-dev ruby-dev build-base git curl ruby-json openssl apache2-utils sqlite-libs sqlite sqlite-dev

RUN mkdir -p /usr/src/app
WORKDIR /usr/src/app

COPY . /usr/src/app

CMD ["/bin/bash", "-c", "ruby server.rb"]
