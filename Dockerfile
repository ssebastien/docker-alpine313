FROM alpine:3.13 AS builder

ARG VERSION_ANSIBLE="3.0.0"
ARG VERSION_ANSIBLE_LINT="5.0.2"
ARG VERSION_MOLECULE="3.0.8"

ENV CRYPTOGRAPHY_DONT_BUILD_RUST=1

RUN apk add --update-cache --no-cache \
        alpine-sdk \
        libffi-dev \
        openssl-dev \
        py3-pip \
        python3 \
        python3-dev

RUN pip install --upgrade --no-cache-dir pip

RUN pip install --no-cache-dir \
        ansible==${VERSION_ANSIBLE} \
        ansible-lint==${VERSION_ANSIBLE_LINT} \
        molecule[docker]==${VERSION_MOLECULE}

FROM alpine:3.13

LABEL maintainer="Sébastien"
LABEL org.opencontainers.image.source="https://github.com/ssebastien/docker-alpine313"

# Install basic tools
RUN apk add --update-cache --no-cache \
        alpine-sdk \
        bash \
        docker-cli \
        htop \
        openssl \
        python3 \
        tmux \
        tree \
        vim \
        zsh

# Copy from builder
COPY --from=builder /usr/lib/python3.8/site-packages/ /usr/lib/python3.8/site-packages/
COPY --from=builder /usr/bin/ansible*  /usr/bin/
COPY --from=builder /usr/bin/molecule  /usr/bin/molecule
COPY --from=builder /usr/bin/yamllint  /usr/bin/yamllint

# Prepare molecule workspace
RUN mkdir /opt/workspace

WORKDIR /opt/workspace

CMD ["/bin/bash"]

