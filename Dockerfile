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
RUN apt-get clean && \
  apt-get update -y --fix-missing && \
  apt-get install -y locales && \
  locale-gen en_US.UTF-8 && \
  dpkg-reconfigure locales && \
  echo "LC_ALL=en_US.UTF-8\nLANG=en_US.UTF-8\nLANGUAGE=en_US.UTF-8" > /etc/default/locale
ENV LC_ALL en_US.UTF-8
RUN echo 'export LC_ALL=en_US.UTF-8' >> /root/.profile
ENV LANG en_US.UTF-8
RUN echo 'export LANG=en_US.UTF-8' >> /root/.profile
ENV LANGUAGE en_US.UTF-8
RUN echo 'export LANGUAGE=en_US.UTF-8' >> /root/.profile

# Basic Linux tools
RUN apt-get update -y --fix-missing && apt-get install -y wget curl \
  sudo \
  unzip zip \
  gnupg gnupg2 \
  jq \
  netcat-openbsd \
  bsdmainutils \
  libxml2-utils \
  build-essential \
  automake autoconf \
  chrpath libxft-dev \
  libfreetype6 libfreetype6-dev \
  libfontconfig1 libfontconfig1-dev

# Docker cli
RUN mkdir -p /tmp/download \
  && curl -s -L "https://download.docker.com/linux/static/stable/x86_64/docker-18.06.3-ce.tgz" | \
    tar -xz -C /tmp/download \
  && mv /tmp/download/docker/docker /usr/bin/ \
  && rm -rf /tmp/download

# Git 2.0
RUN apt-get install -y software-properties-common && \
  add-apt-repository ppa:git-core/ppa && \
  apt-get update -y --fix-missing && \
  apt-get install -y git git-core
RUN git --version

# SSH Daemon
RUN apt-get install -y ssh && \
  mkdir /var/run/sshd && \
  chmod 0755 /var/run/sshd

# Ruby
RUN apt-get update -y --fix-missing && \
  apt-get install -y ruby-dev libmagic-dev zlib1g-dev && \
  gpg --keyserver keyserver.ubuntu.com --recv-keys 409B6B1796C275462A1703113804BB82D39DC0E3 7D2BAF1CF37B13E2069D6956105BD0E739499BDB && \
  curl -L https://get.rvm.io | sudo bash -s stable && \
  echo "source /usr/local/rvm/scripts/rvm" >> /root/.profile && \
  /bin/bash --login -c ". /etc/profile.d/rvm.sh && \
    rvm install ruby-2.7.0 && \
    rvm use 2.7.0 && \
    gem install bundler && \
    gem install xcop && \
    gem install pdd && \
    gem install est"
RUN ruby --version

# PHP
RUN LC_ALL=C.UTF-8 add-apt-repository ppa:ondrej/php && \
  apt-get update -y --fix-missing && \
  apt-get install -y php7.2 php-pear php7.2-curl php7.2-dev php7.2-gd php7.2-mbstring php7.2-zip php7.2-mysql php7.2-xml
RUN curl --silent --show-error https://getcomposer.org/installer | php && \
  mv composer.phar /usr/local/bin/composer
# RUN pecl install xdebug-beta && \
#   echo "zend_extension=xdebug.so" > /etc/php5/cli/conf.d/xdebug.ini
RUN php --version

# Java
RUN apt-get install -y ca-certificates openjdk-11-jdk openjdk-17-jdk
RUN update-java-alternatives --set java-1.11.0-openjdk-amd64
ENV MAVEN_OPTS "-Xmx1g"
ENV JAVA_OPTS "-Xmx1g"
ENV JAVA_HOME "/usr/lib/jvm/java-11-openjdk-amd64"
RUN echo 'export JAVA_HOME=/usr/lib/jvm/java-11-openjdk-amd64' >> /root/.profile
RUN java --version

# PhantomJS
RUN apt-get install -y phantomjs

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
RUN tlmgr install latexmk
RUN latexmk --version

# S3cmd for AWS S3 integration
RUN apt-get install -y s3cmd

# Postgresql
RUN apt-get update -y --fix-missing && \
  apt-get install -y postgresql-client postgresql
USER postgres
RUN /etc/init.d/postgresql start && \
  psql --command "CREATE USER rultor WITH SUPERUSER PASSWORD 'rultor';" && \
  createdb -O rultor rultor
EXPOSE 5432
USER root
ENV PATH="${PATH}:/usr/lib/postgresql/12/bin"
RUN echo 'export PATH=${PATH}:/usr/lib/postgresql/12/bin' >> /root/.profile
RUN initdb --version
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
RUN mvn --version

# Python3
RUN add-apt-repository -y ppa:deadsnakes/ppa
RUN apt-get update -y --fix-missing && \
  apt-get install -y build-essential libpq-dev libssl-dev openssl libffi-dev zlib1g-dev && \
  apt-get install -y python3.7 && \
  apt-get install -y python3-pip python3.7-dev && \
  apt-get update -y --fix-missing && \
  ln -s $(which python3) /usr/bin/python && \
  pip3 install --upgrade pip
RUN python --version
RUN pip --version

# NodeJS
RUN rm -rf /usr/lib/node_modules && \
  (curl -fsSL https://deb.nodesource.com/setup_17.x | sudo -E bash -) && \
  apt-get install -y nodejs
RUN node --version
RUN npm --version

# Rust and Cargo
RUN curl https://sh.rustup.rs -sSf | bash -s -- -y
ENV PATH="${PATH}:${HOME}/.cargo/bin"
RUN echo 'export PATH=${PATH}:${HOME}/.cargo/bin' >> /root/.profile
RUN ${HOME}/.cargo/bin/rustup toolchain install stable

# Clean up
RUN rm -rf /root/.ssh
RUN rm -rf /root/.gnupg

ENTRYPOINT ["/bin/bash", "--login", "-c"]
