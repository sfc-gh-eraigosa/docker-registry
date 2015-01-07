# VERSION 0.1
# DOCKER-VERSION  0.7.3
# AUTHOR:         Sam Alba <sam@docker.com>
# DESCRIPTION:    Image with docker-registry project and dependecies
# TO_BUILD:       docker build -rm -t registry .
# TO_RUN:         docker run -p 5000:5000 registry

# Latest Ubuntu LTS
FROM ubuntu:14.04

# only used durring build time
ADD ./contrib /opt/contrib

# Setup proxy
ENV PROXY "nil"
COPY contrib/proxy_debian.sh /etc/profile.d/

# Update
RUN . /etc/profile \
    && apt-get update -y \
# Install pip
    && apt-get install -y \
        swig \
        python-pip \
# Install deps for backports.lmza (python2 requires it)
        python-dev \
        libssl-dev \
        liblzma-dev \
        libevent1-dev \
    && rm -rf /var/lib/apt/lists/*

COPY . /docker-registry
COPY ./config/boto.cfg /etc/boto.cfg

# Install core
RUN . /opt/contrib/pip_options.sh \
    && pip install $PIP_OPTIONS /docker-registry/depends/docker-registry-core

# Install registry
RUN . /opt/contrib/pip_options.sh \
    && pip install --allow-external Werkzeug $PIP_OPTIONS \
           file:///docker-registry#egg=docker-registry[bugsnag,newrelic,cors]

RUN patch \
 $(python -c 'import boto; import os; print os.path.dirname(boto.__file__)')/connection.py \
 < /docker-registry/contrib/boto_header_patch.diff

ENV DOCKER_REGISTRY_CONFIG /docker-registry/config/config_sample.yml
ENV SETTINGS_FLAVOR dev

EXPOSE 5000

CMD ["docker-registry"]
