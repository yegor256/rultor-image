[![docker](https://github.com/yegor256/rultor-image/actions/workflows/docker.yml/badge.svg)](https://github.com/yegor256/rultor-image/actions/workflows/docker.yml)
[![Docker Cloud Automated build](https://img.shields.io/docker/cloud/automated/yegor256/rultor-image)](https://hub.docker.com/r/yegor256/rultor-image)
[![License](https://img.shields.io/badge/license-MIT-green.svg)](https://github.com/yegor256/total/rultor-image/master/LICENSE.txt)

This is the default Docker image for [Rultor](https://www.rultor.com), available in
Docker Hub as [`yegor256/rultor-image`](https://hub.docker.com/r/yegor256/rultor-image).

This image has the following product installed, in latest versions:

  * Git
  * sshd
  * Ruby
  * PHP
  * Java
  * PhantomJS
  * TeXLive
  * s3cmd
  * PostgreSQL
  * Maven
  * Python
  * NodeJS
  * Go

To use Java 17 do this:

```
$ update-java-alternatives --set java-1.17.0-openjdk-amd64
$ export JAVA_HOME=/usr/lib/jvm/java-17-openjdk-amd64
```

Feel free to add yours by submitting a pull request.
