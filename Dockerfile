# Copyright (c) 2009-2023 Yegor Bugayenko
# All rights reserved.
#
# Redistribution and use in source and binary forms, with or without
# modification, are permitted provided that the following conditions
# are met: 1) Redistributions of source code must retain the above
# copyright notice, this list of conditions and the following
# disclaimer. 2) Redistributions in binary form must reproduce the above
# copyright notice, this list of conditions and the following
# disclaimer in the documentation and/or other materials provided
# with the distribution. 3) Neither the name of the rultor.com nor
# the names of its contributors may be used to endorse or promote
# products derived from this software without specific prior written
# permission.
#
# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
# "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT
# NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND
# FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL
# THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT,
# INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
# (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
# SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION)
# HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT,
# STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
# ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED
# OF THE POSSIBILITY OF SUCH DAMAGE.

# The software packages configured here (PHP, Node, Ruby, Java etc.) are for
# the convenience of the users going to use this default container.
# If you are going to use your own container, you may remove them.
# Rultor has no dependency on these packages.

FROM ubuntu:22.04
MAINTAINER Yegor Bugayenko <yegor256@gmail.com>
LABEL Description="This is the default image for Rultor.com" Vendor="Rultor.com" Version="0.0.0"
WORKDIR /tmp

ENV DEBIAN_FRONTEND=noninteractive

# To disable IPv6
RUN mkdir ~/.gnupg
RUN echo "disable-ipv6" >> ~/.gnupg/dirmngr.conf

# UTF-8 locale
RUN apt-get clean
RUN apt-get update -y --fix-missing
RUN apt-get -y install locales
RUN locale-gen en_US.UTF-8 && \
  dpkg-reconfigure locales && \
  echo "LC_ALL=en_US.UTF-8\nLANG=en_US.UTF-8\nLANGUAGE=en_US.UTF-8" > /etc/default/locale
ENV LC_ALL en_US.UTF-8
RUN echo 'export LC_ALL=en_US.UTF-8' >> /root/.profile
ENV LANG en_US.UTF-8
RUN echo 'export LANG=en_US.UTF-8' >> /root/.profile
ENV LANGUAGE en_US.UTF-8
RUN echo 'export LANGUAGE=en_US.UTF-8' >> /root/.profile

# Basic Linux tools
RUN apt-get -y install wget
RUN apt-get -y install vim
RUN apt-get -y install curl
RUN apt-get -y install sudo
RUN apt-get -y install unzip
RUN apt-get -y install zip
RUN apt-get -y install gnupg2
RUN apt-get -y install jq
RUN apt-get -y install netcat-openbsd
RUN apt-get -y install bsdmainutils
RUN apt-get -y install libxml2-utils
RUN apt-get -y install libjpeg-dev
RUN apt-get -y install aspell
RUN apt-get -y install ghostscript
RUN apt-get -y install build-essential
RUN apt-get -y install automake
RUN apt-get -y install autoconf
RUN apt-get -y install chrpath
RUN apt-get -y install libxft-dev
RUN apt-get -y install libfreetype6
RUN apt-get -y install libfreetype6-dev
RUN apt-get -y install libfontconfig1
RUN apt-get -y install libfontconfig1-dev
RUN apt-get -y install software-properties-common

# LaTeX
RUN mkdir /tmp/texlive \
  && cd /tmp/texlive \
  && wget http://mirror.ctan.org/systems/texlive/tlnet/install-tl.zip \
  && unzip ./install-tl.zip -d install-tl \
  && cd install-tl/install-tl-* \
  && echo "selected_scheme scheme-small" > p \
  && perl ./install-tl --profile=p
RUN ln -s $(ls /usr/local/texlive/2023/bin/) /usr/local/texlive/2023/bin/latest
ENV PATH "${PATH}:/usr/local/texlive/2023/bin/latest"
RUN echo 'export PATH=${PATH}:/usr/local/texlive/2023/bin/latest' >> /root/.profile
RUN tlmgr init-usertree
RUN tlmgr install texliveonfly
RUN pdflatex --version
RUN bash -c '[[ "$(pdflatex --version)" =~ "2.6" ]]'
RUN tlmgr install latexmk
RUN bash -c 'latexmk --version'

# CMake for C/C++ projects
RUN apt-get -y install cmake

# Docker cli
RUN mkdir -p /tmp/download \
  && curl -s -L "https://download.docker.com/linux/static/stable/x86_64/docker-18.06.3-ce.tgz" | \
    tar -xz -C /tmp/download \
  && mv /tmp/download/docker/docker /usr/bin/ \
  && rm -rf /tmp/download

# Git 2.0
RUN add-apt-repository ppa:git-core/ppa
RUN apt-get update -y --fix-missing
RUN apt-get -y install git
RUN bash -c 'git --version'

# SSH Daemon
RUN apt-get -y install ssh
RUN mkdir /var/run/sshd && \
  chmod 0755 /var/run/sshd

# Ruby
RUN apt-get -y install ruby-dev
RUN apt-get -y install libmagic-dev
RUN apt-get -y install zlib1g-dev
RUN gpg --keyserver keyserver.ubuntu.com --recv-keys 409B6B1796C275462A1703113804BB82D39DC0E3 7D2BAF1CF37B13E2069D6956105BD0E739499BDB
RUN curl -L https://get.rvm.io | sudo bash -s stable
RUN echo "source /usr/local/rvm/scripts/rvm && rvm use 3.0.1 && rvm default 3.0.1" >> /root/.profile
RUN bash -l -c ". /etc/profile.d/rvm.sh && rvm pkg install openssl"
RUN bash -l -c ". /etc/profile.d/rvm.sh && rvm install ruby-2.7.6 --with-openssl-dir=/usr/local/rvm/usr"
RUN bash -l -c ". /etc/profile.d/rvm.sh && rvm install ruby-3.0.1 --with-openssl-dir=/usr/local/rvm/usr"
RUN echo 'gem: --no-document' >> ~/.gemrc
RUN bash -l -c ". /etc/profile.d/rvm.sh && \
  rvm use 3.0.1 && \
  gem install bundler -v 2.3.26 && \
  gem install xcop -v 0.7.1 && \
  gem install pdd -v 0.23.1"

# PHP
RUN LC_ALL=C.UTF-8 add-apt-repository ppa:ondrej/php
RUN apt-get update -y --fix-missing
RUN apt-get -y install php7.2
RUN apt-get -y install php-pear
RUN apt-get -y install php7.2-curl
RUN apt-get -y install php7.2-dev
RUN apt-get -y install php7.2-gd
RUN apt-get -y install php7.2-mbstring
RUN apt-get -y install php7.2-zip
RUN apt-get -y install php7.2-mysql
RUN apt-get -y install php7.2-xml
RUN curl --silent --show-error https://getcomposer.org/installer | php
RUN mv composer.phar /usr/local/bin/composer
# RUN pecl install xdebug-beta && \
#   echo "zend_extension=xdebug.so" > /etc/php5/cli/conf.d/xdebug.ini
RUN bash -c 'php --version'

# Java
RUN apt-get -y install ca-certificates
RUN apt-get -y install openjdk-11-jdk
RUN apt-get -y install openjdk-17-jdk
RUN update-java-alternatives --set $(ls /usr/lib/jvm | grep java-1.11)
ENV MAVEN_OPTS "-Xmx1g"
ENV JAVA_OPTS "-Xmx1g"
RUN ln -s "/usr/lib/jvm/$(ls /usr/lib/jvm | grep java-1.11)" /usr/lib/jvm/java-11
RUN ln -s "/usr/lib/jvm/$(ls /usr/lib/jvm | grep java-1.17)" /usr/lib/jvm/java-17
ENV JAVA_HOME "/usr/lib/jvm/java-17"
RUN echo 'export JAVA_HOME=/usr/lib/jvm/java-11' >> /root/.profile
RUN bash -c '[[ "$(javac  --version)" =~ "11.0" ]]'

# QPDF
RUN cd /tmp \
  && git clone https://github.com/qpdf/qpdf \
  && cd qpdf \
  && git checkout v11.2.0 \
  && cmake -S . -B build -DCMAKE_BUILD_TYPE=RelWithDebInfo \
  && cmake --build build \
  && cmake --install build \
  && export LD_LIBRARY_PATH=/usr/local/lib \
  && ldconfig
RUN bash -c '[[ "$(qpdf --version)" =~ "11.2" ]]'

# S3cmd for AWS S3 integration
RUN apt-get -y install s3cmd

# Postgresql
RUN apt-get -y install postgresql-client
RUN apt-get -y install postgresql
RUN bash -c 'psql --version'
USER postgres
RUN /etc/init.d/postgresql start && \
  psql --command "CREATE USER rultor WITH SUPERUSER PASSWORD 'rultor';" && \
  createdb -O rultor rultor
EXPOSE 5432
USER root
ENV PATH="${PATH}:/usr/lib/postgresql/14/bin"
RUN echo 'export PATH=${PATH}:/usr/lib/postgresql/14/bin' >> /root/.profile
RUN bash -c 'initdb --version'
# Postgresql service has to be started using `sudo /etc/init.d/postgresql start` in .rultor.yml

# Maven
ENV MAVEN_VERSION 3.9.1
ENV M2_HOME "/usr/local/apache-maven/apache-maven-${MAVEN_VERSION}"
RUN echo 'export M2_HOME=/usr/local/apache-maven/apache-maven-${MAVEN_VERSION}' >> /root/.profile
RUN wget --quiet "https://dlcdn.apache.org/maven/maven-3/${MAVEN_VERSION}/binaries/apache-maven-${MAVEN_VERSION}-bin.tar.gz" && \
  mkdir -p /usr/local/apache-maven && \
  mv "apache-maven-${MAVEN_VERSION}-bin.tar.gz" /usr/local/apache-maven && \
  tar xzvf "/usr/local/apache-maven/apache-maven-${MAVEN_VERSION}-bin.tar.gz" -C /usr/local/apache-maven/ && \
  update-alternatives --install /usr/bin/mvn mvn "${M2_HOME}/bin/mvn" 1 && \
  update-alternatives --config mvn && \
  mvn -version
COPY settings.xml /root/.m2/settings.xml
RUN bash -c '[[ "$(mvn --version)" =~ "${MAVEN_VERSION}" ]]'

# Python3
RUN add-apt-repository -y ppa:deadsnakes/ppa
RUN apt-get update -y --fix-missing
RUN apt-get -y install libpq-dev
RUN apt-get -y install libssl-dev
RUN apt-get -y install openssl
RUN apt-get -y install libffi-dev
RUN apt-get -y install python3.7
RUN apt-get -y install python3-pip
RUN apt-get -y install python3.7-dev
RUN ln -s $(which python3) /usr/bin/python
RUN bash -c 'python --version'
RUN pip3 install -Iv --upgrade pip
RUN bash -c 'pip --version'

# Pygments
RUN apt-get -y install python3-pygments
RUN pip3 install -Iv pygments

# NodeJS
RUN rm -rf /usr/lib/node_modules
RUN apt-get -y install nodejs
RUN bash -c 'node --version'
RUN apt-get -y install npm
RUN bash -c 'npm --version'

# Rust and Cargo
RUN curl https://sh.rustup.rs -sSf | bash -s -- -y
ENV PATH="${PATH}:${HOME}/.cargo/bin"
RUN echo 'export PATH=${PATH}:${HOME}/.cargo/bin' >> /root/.profile
RUN ${HOME}/.cargo/bin/rustup toolchain install stable
RUN bash -c '"${HOME}/.cargo/bin/cargo" --version'

# Go
RUN apt-get update
RUN apt-get install -y golang
RUN bash -c 'go version'

# Clean up
RUN rm -rf /tmp/*
RUN rm -rf /root/.ssh
RUN rm -rf /root/.cache
RUN rm -rf /root/.wget-hsts
RUN rm -rf /root/.gnupg

ENTRYPOINT ["/bin/bash", "--login", "-c"]
