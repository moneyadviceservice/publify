FROM masdevtestregistry.azurecr.io/jenkins/ruby2.5.3:latest
MAINTAINER development.team@moneyadviceservice.org.uk

RUN apt-get -qq update > /dev/null && \
  apt-get -qq dist-upgrade > /dev/null && \
  apt-get -qq clean  > /dev/null && \
  apt-get install libcurl4-gnutls-dev && \
  rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

COPY . /var/tmp/app/
