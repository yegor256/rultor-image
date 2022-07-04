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

Feel free to add yours by submitting a pull request.

To release a new version of this Docker image:

```
$ docker build . --tag yegor256/rultor-image:1.8.0
$ docker push yegor256/rultor-image:1.8.0
$ git tag 1.8.0
```