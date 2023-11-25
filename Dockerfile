FROM alpine:3.17
LABEL maintainer "Rahmi Sacal <fluentd@googlegroups.com>"
LABEL Description="Fluentd docker image" Vendor="Turkcell" Version="1.16.1"

RUN apk update \
 && apk add --no-cache \
        ca-certificates \
        ruby ruby-irb ruby-etc ruby-webrick \
        tini \
 && apk add --no-cache --virtual .build-deps \
        build-base linux-headers \
        ruby-dev gnupg \
 && echo 'gem: --no-document' >> /etc/gemrc \
 && gem install oj -v 3.14.3 \
 && gem install json -v 2.6.3 \
 && gem install rexml -v 3.2.5 \
 && gem install async -v 1.31.0 \
 && gem install async-http -v 0.60.1 \
 && gem install fluentd -v 1.16.2 \
 && gem install bigdecimal -v 1.4.4 \
 && gem install fluent-plugin-splunk-enterprise \
 && gem install fluent-plugin-splunk-hec \
 && gem install fluent-plugin-rewrite-tag-filter \
 && gem install fileutils \
 && gem install fluent-plugin-concat \
 && gem install fluent-plugin-jq \
 && gem install fluent-plugin-kubernetes_metadata_filter \
 && gem install fluent-plugin-prometheus \
 && gem install fluent-plugin-record-modifier \
 && gem install fluent-plugin-systemd \
 && apk del .build-deps \
 && rm -rf /tmp/* /var/tmp/* /usr/lib/ruby/gems/*/cache/*.gem /usr/lib/ruby/gems/3.*/gems/fluentd-*/test

RUN addgroup -S fluent && adduser -S -G fluent fluent \
    # for log storage (maybe shared with host)
    && mkdir -p /fluentd/log \
    # configuration/plugins path (default: copied from .)
    && mkdir -p /fluentd/etc /fluentd/plugins \
    && chown -R fluent /fluentd && chgrp -R fluent /fluentd


#COPY fluent.conf /fluentd/etc/
COPY entrypoint.sh /bin/
RUN chmod +x /bin/entrypoint.sh

ENV FLUENTD_CONF="fluent.conf"

ENV LD_PRELOAD=""
EXPOSE 24224 20001

USER fluent
ENTRYPOINT ["tini",  "--", "/bin/entrypoint.sh"]
CMD ["fluentd"]