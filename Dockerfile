FROM maven:3-jdk-8-alpine AS build
ARG NEXUS_VERSION=3.19.1
ARG NEXUS_BUILD=01
ENV NEXUS_VERSION=${NEXUS_VERSION} \
    NEXUS_BUILD=${NEXUS_BUILD}

COPY nexus-repository-composer/. /nexus-repository-composer/
COPY nexus-repository-apk/. /nexus-repository-apk/

# Composer build
RUN cd /nexus-repository-composer/; sed -i "s/3.19.1-01/${NEXUS_VERSION}-${NEXUS_BUILD}/g" pom.xml; \
    mvn clean package;
# APK Build
RUN cd /nexus-repository-apk/; \
    mvn clean package -PbuildKar;

FROM sonatype/nexus3:$NEXUS_VERSION

# APK settings
ARG FORMAT_VERSION=0.0.5-SNAPSHOT
ARG DEPLOY_DIR=/opt/sonatype/nexus/deploy/

# Composer settings
ARG NEXUS_VERSION=3.19.1
ARG NEXUS_BUILD=01
ARG COMPOSER_VERSION=0.0.5-SNAPSHOT
ARG TARGET_DIR=/opt/sonatype/nexus/system/org/sonatype/nexus/plugins/nexus-repository-composer/${COMPOSER_VERSION}/
ENV NEXUS_VERSION=${NEXUS_VERSION} \
    NEXUS_BUILD=${NEXUS_BUILD}

USER root
# Copy APK kar
COPY --from=build /nexus-repository-apk/nexus-repository-apk/target/nexus-repository-apk-${FORMAT_VERSION}-bundle.kar ${DEPLOY_DIR}
# Copy Composer jar
RUN mkdir -p ${TARGET_DIR}; \
    sed -i 's@nexus-repository-maven</feature>@nexus-repository-maven</feature>\n        <feature prerequisite="false" dependency="false" version="0.0.2">nexus-repository-composer</feature>@g' /opt/sonatype/nexus/system/org/sonatype/nexus/assemblies/nexus-core-feature/${NEXUS_VERSION}-${NEXUS_BUILD}/nexus-core-feature-${NEXUS_VERSION}-${NEXUS_BUILD}-features.xml; \
    sed -i 's@<feature name="nexus-repository-maven"@<feature name="nexus-repository-composer" description="org.sonatype.nexus.plugins:nexus-repository-composer" version="0.0.2">\n        <details>org.sonatype.nexus.plugins:nexus-repository-composer</details>\n        <bundle>mvn:org.sonatype.nexus.plugins/nexus-repository-composer/0.0.2</bundle>\n    </feature>\n    <feature name="nexus-repository-maven"@g' /opt/sonatype/nexus/system/org/sonatype/nexus/assemblies/nexus-core-feature/${NEXUS_VERSION}-${NEXUS_BUILD}/nexus-core-feature-${NEXUS_VERSION}-${NEXUS_BUILD}-features.xml;
COPY --from=build /nexus-repository-composer/target/nexus-repository-composer-${COMPOSER_VERSION}.jar ${TARGET_DIR}
USER nexus
