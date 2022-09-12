# Fluentd Image to Forward Logs from FID to SPLUNK

# Packaging fid-exporter image with fluentd
FROM alpine:latest
LABEL maintainer "Radiant Logic SAAS&CLOUD Team <saas@radiantlogic.com>"
LABEL Description="Fluentd image for forwarding logs to SPLUNK" Vendor="Radiant Logic" 
USER root
# Installing fluentd
RUN apk update \
 && apk upgrade \
 && apk add --no-cache \
        ca-certificates \
        ruby ruby-irb ruby-etc ruby-webrick \
        tini curl\
 && apk add --no-cache --virtual .build-deps \
        build-base linux-headers \
        ruby-dev gnupg \
 && echo 'gem: --no-document' >> /etc/gemrc \
 && gem install oj -v 3.10.18 \
 && gem install json -v 2.4.1 \
 && gem install async-http -v 0.54.0 \
 && gem install faraday -v 1.10.2\
 && gem install yajl-ruby -v 1.4.1 \
 && gem install faraday-net_http -v 2.1.0 \
 && gem install minitest -v 5.15.0 \
 && gem install activesupport -v 7.0.4 \
 && gem install fluentd -v 1.14.5 \
 && gem install bigdecimal -v 1.4.4 \
 && apk del .build-deps \
 && rm -rf /tmp/* /var/tmp/* /usr/lib/ruby/gems/*/cache/*.gem /usr/lib/ruby/gems/2.*/gems/fluentd-*/test



# Adding non-root user
RUN addgroup -g 1000 -S fidexporter && adduser -u 1000 -S -g fidexporter fidexporter \
    && mkdir -p /fluentd/etc /fluentd/plugins /opt/fidexporter /fluentd/log \
    && chown -R fidexporter /fluentd && chgrp -R fidexporter /fluentd \
    && chown -R fidexporter /opt/fidexporter && chgrp -R fidexporter /opt/fidexporter \
    && chown -R fidexporter /fluentd && chgrp -R fidexporter /fluentd

COPY ./fluentd/fluent.conf /opt/fidexporter/fluent.conf
COPY entrypoint.sh /opt/fidexporter/entrypoint.sh

# ONBUILD COPY fluent.conf /fluentd/etc/
# ONBUILD COPY plugins /fluentd/plugins/

# adding fluentd plugins
RUN apk add --no-cache --update --virtual .build-deps \
        build-base ruby-dev \
 && gem install fluent-plugin-elasticsearch\
 && gem install fluent-plugin-grok-parser \
 && fluent-gem install fluent-plugin-splunk-enterprise \
 && gem install fluent-plugin-splunk-hec \
 && gem sources --clear-all \
 && apk del .build-deps \
 && rm -rf /tmp/* /var/tmp/* /usr/lib/ruby/gems/*/cache/*.gem


EXPOSE 9095 24224 5140
HEALTHCHECK  --interval=1m --timeout=30s --retries=3 \
  CMD nc -w 2 -z 127.0.0.1 9095
RUN chmod +x ./opt/fidexporter/entrypoint.sh 
USER fidexporter
ENTRYPOINT ["/bin/sh","-c","./opt/fidexporter/entrypoint.sh"]