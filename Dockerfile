FROM alpine:3.7

ENV CLOUD_SDK_VERSION 193.0.0
ENV HELM_VERSION 2.7.2

ENV PATH /google-cloud-sdk/bin:$PATH

ADD assets /opt/resource
RUN chmod +x /opt/resource/*

RUN apk --no-cache add \
        curl \
        python \
        py-crcmod \
        bash \
        libc6-compat \
        openssh-client \
        git \
        openssl \
        tar \
        ca-certificates

RUN curl -O https://dl.google.com/dl/cloudsdk/channels/rapid/downloads/google-cloud-sdk-${CLOUD_SDK_VERSION}-linux-x86_64.tar.gz \
        && tar xzf google-cloud-sdk-${CLOUD_SDK_VERSION}-linux-x86_64.tar.gz \
        && rm google-cloud-sdk-${CLOUD_SDK_VERSION}-linux-x86_64.tar.gz \
        && ln -s /lib /lib64 \
        && gcloud config set core/disable_usage_reporting true \
        && gcloud config set component_manager/disable_update_check true \
        && gcloud config set metrics/environment github_docker_image \
        && gcloud --version \
        && gcloud components install alpha beta kubectl \
        && gcloud components update

RUN curl -L -o helm.tar.gz \
        https://kubernetes-helm.storage.googleapis.com/helm-v${HELM_VERSION}-linux-amd64.tar.gz \
        && tar -xvzf helm.tar.gz \
        && rm -rf helm.tar.gz \
        && chmod 0700 linux-amd64/helm \
        && mv linux-amd64/helm /usr/bin \
        && rm -rf linux-amd64 \
        && helm init --client-only \
        && helm plugin install https://github.com/viglesiasce/helm-gcs.git

ENTRYPOINT [ "/bin/bash" ]
