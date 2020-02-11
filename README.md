# Nexus OSS Repository with Alpine APK and PHP Composer

Provided here is a Dockerfile to build the Alpine APK and PHP Composer plugins for Nexus OSS and then install them into a Nexus OSS container that can be deployed with both modules ready to run out of the box.

To build, clone this repository and initialize the submodules.
```  
  git submodule init
  git submodule update
```


## Versioning
Because this project is a derivative of the Nexus OSS releases we use an additional set of version numbers numbers to define the state of this repositories code.

The Docker image contains the Nexus version along with the local version of this code. The format for versioning include the version of Nexus OSS being used followed by the version of this software.

Example: `nexus-repository-apk-composer:3.19.1-0.0.1`

Where the version of Nexus OSS being used is `3.19.1` and the version of this code is `0.0.1`
