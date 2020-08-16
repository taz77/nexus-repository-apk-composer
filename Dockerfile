# Global Arg
ARG NEXUS_VERSION=3.26.1
ARG NEXUS_BUILD=02
FROM maven:3-jdk-8-alpine AS build
# Passing global vars into this stage of the build
ARG NEXUS_VERSION
ARG NEXUS_BUILD
ENV NEXUS_VERSION=${NEXUS_VERSION} \
    NEXUS_BUILD=${NEXUS_BUILD}

COPY nexus-repository-composer/. /nexus-repository-composer/
COPY nexus-repository-apk/. /nexus-repository-apk/

# Composer build
RUN cd /nexus-repository-composer/; sed -i "s/3.20.1.1-01/${NEXUS_VERSION}-${NEXUS_BUILD}/g" pom.xml; \
    mvn clean package -PbuildKar;
# APK Build
RUN cd /nexus-repository-apk/; \
    mvn clean package -PbuildKar;

# Installation stage
FROM sonatype/nexus3:${NEXUS_VERSION}
# Passing global vars into this stage of the build
ARG NEXUS_VERSION
ARG NEXUS_BUILD

# APK settings
ARG FORMAT_VERSION=0.0.5-SNAPSHOT
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