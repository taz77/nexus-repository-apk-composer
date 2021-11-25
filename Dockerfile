# Global Arg
ARG NEXUS_VERSION=3.37.0
ARG NEXUS_BUILD=01
FROM maven:3-jdk-8-alpine AS build
# Passing global vars into this stage of the build
ARG NEXUS_VERSION
ARG NEXUS_BUILD
ENV NEXUS_VERSION=${NEXUS_VERSION} \
    NEXUS_BUILD=${NEXUS_BUILD}

COPY nexus-repository-composer/. /nexus-repository-composer/
COPY nexus-repository-apk/. /nexus-repository-apk/

# This section can be used if you want to build behind a cache proxy
# Since we want to execute the mvn command with RUN (and not when the container gets started),
# we have to do here some manual setup which would be made by the maven's entrypoint script
# RUN mkdir -p /root/.m2 \
#     && mkdir /root/.m2/repository
# # Copy maven settings, containing repository configurations
# COPY settings.xml /root/.m2

# Composer build
RUN cd /nexus-repository-composer/; \
    mvn clean package -q -PbuildKar;
# APK Build
RUN cd /nexus-repository-apk/; \
    mvn clean package -q -PbuildKar;

# Installation stage
FROM sonatype/nexus3:${NEXUS_VERSION}
# Passing global vars into this stage of the build
ARG NEXUS_VERSION
ARG NEXUS_BUILD

# APK settings
ARG FORMAT_VERSION=0.0.24-SNAPSHOT
ARG DEPLOY_DIR=/opt/sonatype/nexus/deploy/

# Composer settings
ARG NEXUS_VERSION
ARG NEXUS_BUILD
ENV NEXUS_VERSION=${NEXUS_VERSION} \
    NEXUS_BUILD=${NEXUS_BUILD}

USER root
# Copy APK kar
COPY --from=build /nexus-repository-apk/nexus-repository-apk/target/nexus-repository-apk-${FORMAT_VERSION}-bundle.kar ${DEPLOY_DIR}
# Copy Composer kar
COPY --from=build /nexus-repository-composer/nexus-repository-composer/target/nexus-repository-composer-*-bundle.kar ${DEPLOY_DIR}
USER nexus