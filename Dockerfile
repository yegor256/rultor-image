# Copyright (c) 2009-2022 Yegor Bugayenko
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

FROM ubuntu:20.04
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
RUN apt-get -y install locales=2.31-0ubuntu9.9
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
RUN apt-get -y install wget=1.20.3-1ubuntu2
RUN apt-get -y install vim=2:8.1.2269-1ubuntu5.9
RUN apt-get -y install curl=7.68.0-1ubuntu2.14
RUN apt-get -y install sudo=1.8.31-1ubuntu1.2
RUN apt-get -y install unzip=6.0-25ubuntu1.1
RUN apt-get -y install zip=3.0-11build1
RUN apt-get -y install gnupg2=2.2.19-3ubuntu2.2
RUN apt-get -y install jq=1.6-1ubuntu0.20.04.1
RUN apt-get -y install netcat-openbsd=1.206-1ubuntu1
RUN apt-get -y install bsdmainutils=11.1.2ubuntu3
RUN apt-get -y install libxml2-utils=2.9.10+dfsg-5ubuntu0.20.04.5
RUN apt-get -y install libjpeg-dev=8c-2ubuntu8
RUN apt-get -y install aspell=0.60.8-1ubuntu0.1
RUN apt-get -y install ghostscript=9.50~dfsg-5ubuntu4.6
RUN apt-get -y install build-essential=12.8ubuntu1.1
RUN apt-get -y install automake=1:1.16.1-4ubuntu6
RUN apt-get -y install autoconf=2.69-11.1
RUN apt-get -y install chrpath=0.16-2
RUN apt-get -y install libxft-dev=2.3.3-0ubuntu1
RUN apt-get -y install libfreetype6=2.10.1-2ubuntu0.2
RUN apt-get -y install libfreetype6-dev=2.10.1-2ubuntu0.2
RUN apt-get -y install libfontconfig1=2.13.1-2ubuntu3
RUN apt-get -y install libfontconfig1-dev=2.13.1-2ubuntu3
RUN apt-get -y install software-properties-common=0.99.9.8

# LaTeX
RUN mkdir /tmp/texlive \
  && cd /tmp/texlive \
  && wget http://mirror.ctan.org/systems/texlive/tlnet/install-tl.zip \
  && unzip ./install-tl.zip -d install-tl \
  && cd install-tl/install-tl-* \
  && echo "selected_scheme scheme-small" > p \
  && perl ./install-tl --profile=p
# It's better to do it like this, but Docker has a bug:
# https://stackoverflow.com/a/41864647/187141
# ENV PATH "${PATH}:$(realpath /usr/local/texlive/*/bin/*)"
ENV PATH "${PATH}:/usr/local/texlive/2022/bin/x86_64-linux"
RUN echo 'export PATH=${PATH}:/usr/local/texlive/2022/bin/x86_64-linux' >> /root/.profile
RUN tlmgr init-usertree
RUN tlmgr install texliveonfly
RUN pdflatex --version
RUN bash -c '[[ "$(pdflatex --version)" =~ "2.6" ]]'
RUN tlmgr install latexmk
RUN bash -c '[[ "$(latexmk --version)" =~ "4.78" ]]'

# CMake for C/C++ projects
RUN apt-get -y install cmake=3.16.3-1ubuntu1.20.04.1

# Docker cli
RUN mkdir -p /tmp/download \
  && curl -s -L "https://download.docker.com/linux/static/stable/x86_64/docker-18.06.3-ce.tgz" | \
    tar -xz -C /tmp/download \
  && mv /tmp/download/docker/docker /usr/bin/ \
  && rm -rf /tmp/download

# Git 2.0
RUN add-apt-repository ppa:git-core/ppa
RUN apt-get update -y --fix-missing
RUN apt-get -y install git=1:2.39.0-0ppa1~ubuntu20.04.1
RUN bash -c '[[ "$(git --version)" =~ "2.39" ]]'

# SSH Daemon
RUN apt-get -y install ssh=1:8.2p1-4ubuntu0.5
RUN mkdir /var/run/sshd && \
  chmod 0755 /var/run/sshd

# Ruby
RUN apt-get -y install ruby-dev=1:2.7+1
RUN apt-get -y install libmagic-dev=1:5.38-4
RUN apt-get -y install zlib1g-dev=1:1.2.11.dfsg-2ubuntu1.5
RUN gpg --keyserver keyserver.ubuntu.com --recv-keys 409B6B1796C275462A1703113804BB82D39DC0E3 7D2BAF1CF37B13E2069D6956105BD0E739499BDB
RUN curl -L https://get.rvm.io | sudo bash -s stable
RUN echo "source /usr/local/rvm/scripts/rvm && rvm use 3.0.1 && rvm default 3.0.1" >> /root/.profile
RUN bash -l -c ". /etc/profile.d/rvm.sh && rvm install ruby-2.7.0"
RUN bash -l -c ". /etc/profile.d/rvm.sh && rvm install ruby-3.0.1"
RUN echo 'gem: --no-document' >> ~/.gemrc
RUN bash -l -c ". /etc/profile.d/rvm.sh && \
  rvm use 3.0.1 && \
  gem install bundler -v 2.3.26 && \
  gem install xcop -v 0.7.1 && \
  gem install pdd -v 0.23.1 && \
  gem install est -v 0.3.4"

# PHP
RUN LC_ALL=C.UTF-8 add-apt-repository ppa:ondrej/php
RUN apt-get update -y --fix-missing
RUN apt-get -y install php7.2=7.2.34-36+ubuntu20.04.1+deb.sury.org+1
RUN apt-get -y install php-pear=1:1.10.13+submodules+notgz+2022032202-2+ubuntu20.04.1+deb.sury.org+1
RUN apt-get -y install php7.2-curl=7.2.34-36+ubuntu20.04.1+deb.sury.org+1
RUN apt-get -y install php7.2-dev=7.2.34-36+ubuntu20.04.1+deb.sury.org+1
RUN apt-get -y install php7.2-gd=7.2.34-36+ubuntu20.04.1+deb.sury.org+1
RUN apt-get -y install php7.2-mbstring=7.2.34-36+ubuntu20.04.1+deb.sury.org+1
RUN apt-get -y install php7.2-zip=7.2.34-36+ubuntu20.04.1+deb.sury.org+1
RUN apt-get -y install php7.2-mysql=7.2.34-36+ubuntu20.04.1+deb.sury.org+1
RUN apt-get -y install php7.2-xml=7.2.34-36+ubuntu20.04.1+deb.sury.org+1
RUN curl --silent --show-error https://getcomposer.org/installer | php
RUN mv composer.phar /usr/local/bin/composer
# RUN pecl install xdebug-beta && \
#   echo "zend_extension=xdebug.so" > /etc/php5/cli/conf.d/xdebug.ini
RUN bash -c '[[ "$(php --version)" =~ "7.2" ]]'

# Java
RUN apt-get -y install ca-certificates=20211016ubuntu0.20.04.1
RUN apt-get -y install openjdk-11-jdk=11.0.17+8-1ubuntu2~20.04
RUN apt-get -y install openjdk-17-jdk=17.0.5+8-2ubuntu1~20.04
RUN update-java-alternatives --set java-1.11.0-openjdk-amd64
ENV MAVEN_OPTS "-Xmx1g"
ENV JAVA_OPTS "-Xmx1g"
ENV JAVA_HOME "/usr/lib/jvm/java-11-openjdk-amd64"
RUN echo 'export JAVA_HOME=/usr/lib/jvm/java-11-openjdk-amd64' >> /root/.profile
RUN bash -c '[[ "$(javac --version)" =~ "11.0" ]]'

# PhantomJS
RUN apt-get -y install phantomjs=2.1.1+dfsg-2ubuntu1

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
RUN apt-get -y install s3cmd=2.0.2-1ubuntu1

# Postgresql
RUN apt-get -y install postgresql-client=12+214ubuntu0.1
RUN apt-get -y install postgresql=12+214ubuntu0.1
RUN bash -c '[[ "$(psql --version)" =~ "12.12" ]]'
USER postgres
RUN /etc/init.d/postgresql start && \
  psql --command "CREATE USER rultor WITH SUPERUSER PASSWORD 'rultor';" && \
  createdb -O rultor rultor
EXPOSE 5432
USER root
ENV PATH="${PATH}:/usr/lib/postgresql/12/bin"
RUN echo 'export PATH=${PATH}:/usr/lib/postgresql/12/bin' >> /root/.profile
RUN bash -c '[[ "$(initdb --version)" =~ "12.12" ]]'
# Postgresql service has to be started using `sudo /etc/init.d/postgresql start` in .rultor.yml

# Maven
ENV MAVEN_VERSION 3.8.6
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
RUN apt-get -y install libpq-dev=12.12-0ubuntu0.20.04.1
RUN apt-get -y install libssl-dev=1.1.1f-1ubuntu2.16
RUN apt-get -y install openssl=1.1.1f-1ubuntu2.16
RUN apt-get -y install libffi-dev=3.3-4
RUN apt-get -y install python3.7=3.7.16-1+focal1
RUN apt-get -y install python3-pip=20.0.2-5ubuntu1.6
RUN apt-get -y install python3.7-dev=3.7.16-1+focal1
RUN ln -s $(which python3) /usr/bin/python
RUN pip3 install -Iv --upgrade pip==22.3.1
RUN bash -c '[[ "$(python --version)" =~ "3.8" ]]'
RUN bash -c '[[ "$(pip --version)" =~ "22.3" ]]'

# Pygments
RUN apt-get -y install python3-pygments=2.3.1+dfsg-1ubuntu2.2
RUN pip3 install -Iv pygments==2.13.0

# NodeJS
RUN rm -rf /usr/lib/node_modules && \
  (curl -fsSL https://deb.nodesource.com/setup_17.x | sudo -E bash -)
RUN apt-get -y install nodejs=17.9.0-deb-1nodesource1
RUN bash -c '[[ "$(node --version)" =~ "17.9" ]]'
RUN bash -c '[[ "$(npm --version)" =~ "8.5" ]]'

# Rust and Cargo
RUN curl https://sh.rustup.rs -sSf | bash -s -- -y
ENV PATH="${PATH}:${HOME}/.cargo/bin"
RUN echo 'export PATH=${PATH}:${HOME}/.cargo/bin' >> /root/.profile
RUN ${HOME}/.cargo/bin/rustup toolchain install stable
RUN bash -c '[[ "$(${HOME}/.cargo/bin/cargo --version)" =~ "1.66" ]]'

# Clean up
RUN rm -rf /tmp/*
RUN rm -rf /root/.ssh
RUN rm -rf /root.cache
RUN rm -rf /root.wget-hsts
RUN rm -rf /root/.gnupg

ENTRYPOINT ["/bin/bash", "--login", "-c"]
