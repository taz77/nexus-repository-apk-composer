# Nexus OSS Repository with Alpine APK and PHP Composer

## NOTICE
Nexus version used in this Docker container has a critical security vulnerbility. Follow this [issue](https://github.com/taz77/nexus-repository-apk-composer/issues/1) for more information and for updates.

Provided here is a Dockerfile to build the Alpine APK and PHP Composer plugins for Nexus OSS and then install them into a Nexus OSS container that can be deployed with both modules ready to run out of the box.

The Dockerfile here is a multi-staged build to create a consolidated image of the modules. This Dockerfile is also a templat for building your own Nexus Docker image with pre-installed community modules.

The Nexus OSS Image created via this build contains the following community modules
* [Nexus Alpine APK](https://github.com/sonatype-nexus-community/nexus-repository-apk)
* [Nexus PHP Composer](https://github.com/sonatype-nexus-community/nexus-repository-composer)

To build, clone this repository and initialize the submodules to pull down the APK and Composer repos.
```  
  git submodule init
  git submodule update
```

After the required data is pulled down you can now build the image.
```
docker build . -t nexus-cache-repo
```

## Compose Files
Contained in this repository is a `docker-compose.yml` can be used to create a local build of this repository via `docker-compose`. For stack deployments (Swarm) there is an example file named `docker-stack-compose.yml`.

## Versions
Major version 1 of this container corresponds to 3.41 and greater of Nexus

