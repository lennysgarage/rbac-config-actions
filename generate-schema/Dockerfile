FROM registry.access.redhat.com/ubi8/ubi

ARG TARGETARCH
USER root
RUN yum install -y tar gzip unzip git

# install platform specific go version
RUN curl -O -J  https://dl.google.com/go/go1.22.7.linux-${TARGETARCH}.tar.gz
RUN tar -C /usr/local -xzf go1.22.7.linux-${TARGETARCH}.tar.gz
RUN ln -s /usr/local/go/bin/go /usr/local/bin/go

COPY entrypoint.sh /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]