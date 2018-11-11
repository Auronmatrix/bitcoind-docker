FROM debian:stretch-slim

RUN useradd -r bitcoin \
  && apt-get update -y \
  && apt-get install -y curl gnupg \
  && apt-get clean \
  && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* \
  && set -ex \
  && for key in \
    B42F6819007F00F88E364FD4036A9C25BF357DD4 \
  ; do \
    gpg --no-tty --keyserver pgp.mit.edu --recv-keys "$key" || \
    gpg --no-tty --keyserver keyserver.pgp.com --recv-keys "$key" || \
    gpg --no-tty --keyserver ha.pool.sks-keyservers.net --recv-keys "$key" || \
    gpg --no-tty --keyserver hkp://p80.pool.sks-keyservers.net:80 --recv-keys "$key" ; \
  done

ENV VERSION=0.17.0
ENV BUILD=x86_64-linux-gnu
ENV PATH=/opt/bitcoin-${VERSION}/bin:$PATH
ENV BITCOIN_DATA=/bitcoin/data

ENV GOSU_VERSION=1.10

RUN curl -o /usr/local/bin/gosu -fSL https://github.com/tianon/gosu/releases/download/${GOSU_VERSION}/gosu-$(dpkg --print-architecture) \
  && curl -o /usr/local/bin/gosu.asc -fSL https://github.com/tianon/gosu/releases/download/${GOSU_VERSION}/gosu-$(dpkg --print-architecture).asc \
  && gpg --verify --no-tty /usr/local/bin/gosu.asc \
  && rm /usr/local/bin/gosu.asc \
  && chmod +x /usr/local/bin/gosu

RUN curl -SL https://bitcoin.org/laanwj-releases.asc | gpg --import --no-tty \
  && curl -SLO https://bitcoin.org/bin/bitcoin-core-${VERSION}/SHA256SUMS.asc \
  && curl -SLO https://bitcoin.org/bin/bitcoin-core-${VERSION}/bitcoin-${VERSION}-${BUILD}.tar.gz \
  && gpg --verify SHA256SUMS.asc \
  && grep " bitcoin-${VERSION}-${BUILD}.tar.gz\$" SHA256SUMS.asc | sha256sum -c - \
  && tar -xzf *.tar.gz -C /opt \
  && rm *.tar.gz *.asc

WORKDIR /bitcoin

VOLUME ["/bitcoin/data"]

COPY bitcoin.conf /bitcoin/bitcoin.conf
COPY docker-entrypoint.sh /docker-entrypoint.sh

RUN chown bitcoin:bitcoin /docker-entrypoint.sh
RUN chmod +x /docker-entrypoint.sh

EXPOSE 8332 8333 18332 18333

ENTRYPOINT ["/docker-entrypoint.sh"]

CMD ["-conf=/bitcoin/bitcoin.conf", "-printtoconsole"]