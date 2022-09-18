# Global Arg
ARG NEXUS_VERSION=3.41.1
ARG NEXUS_BUILD=01
FROM maven:3.8.4-jdk-8-slim AS build
# Passing global vars into this stage of the build
ARG NEXUS_VERSION
ARG NEXUS_BUILD
ENV NEXUS_VERSION=${NEXUS_VERSION} \
    NEXUS_BUILD=${NEXUS_BUILD}

# This section can be used if you want to build behind a cache proxy
# Since we want to execute the mvn command with RUN (and not when the container gets started),
# we have to do here some manual setup which would be made by the maven's entrypoint script
# RUN mkdir -p /root/.m2 \
#     && mkdir /root/.m2/repository
# # Copy maven settings, containing repository configurations
# COPY settings.xml /root/.m2


RUN apt-get update \
    ; \
    apt-get install -y wget \
    ; \
    mkdir /tmp/build \
    ; \
    cd /tmp/build \
    ; \
    wget https://github.com/sonatype-nexus-community/nexus-repository-composer/archive/refs/tags/composer-parent-0.0.23.tar.gz \
    ; \
    wget https://github.com/sonatype-nexus-community/nexus-repository-apk/archive/refs/tags/apk-parent-0.0.26.tar.gz \
    ; \
    tar -xvf apk-parent-0.0.26.tar.gz \
    ; \
    tar -xvf composer-parent-0.0.23.tar.gz \
    ; \
    cd nexus-repository-apk-apk-parent-0.0.26 \
    ; \
    mvn clean package -q -PbuildKar \
    ; \
    cd .. \
    ; \
    cd nexus-repository-composer-composer-parent-0.0.23 \
    ; \
    mvn clean package -q -PbuildKar


# Installation stage
FROM sonatype/nexus3:${NEXUS_VERSION}
# Passing global vars into this stage of the build
ARG NEXUS_VERSION
ARG NEXUS_BUILD

ARG DEPLOY_DIR=/opt/sonatype/nexus/deploy/

# Composer settings
ARG NEXUS_VERSION
ARG NEXUS_BUILD
ENV NEXUS_VERSION=${NEXUS_VERSION} \
    NEXUS_BUILD=${NEXUS_BUILD}

USER root
# Copy APK kar
COPY --from=build /tmp/build/nexus-repository-apk-apk-parent-0.0.26/nexus-repository-apk/target/nexus-repository-apk-0.0.26-bundle.kar ${DEPLOY_DIR}
# Copy Composer kar
COPY --from=build /tmp/build/nexus-repository-composer-composer-parent-0.0.23/nexus-repository-composer/target/nexus-repository-composer-0.0.23-bundle.kar ${DEPLOY_DIR}
USER nexus