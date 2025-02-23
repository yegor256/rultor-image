# SPDX-FileCopyrightText: Copyright (c) 2009-2025 Yegor Bugayenko
# SPDX-License-Identifier: MIT

# The software packages configured here (PHP, Node, Ruby, Java etc.) are for
# the convenience of the users going to use this default container.
# If you are going to use your own container, you may remove them.
# Rultor has no dependency on these packages.

FROM ubuntu:22.04
LABEL Description="This is the default image for Rultor.com" Version="0.0.0"
WORKDIR /tmp

ENV DEBIAN_FRONTEND=noninteractive

# To disable IPv6
RUN mkdir ~/.gnupg \
  && printf "disable-ipv6" >> ~/.gnupg/dirmngr.conf

# UTF-8 locale
RUN apt-get clean \
  && apt-get update -y --fix-missing \
  && apt-get -y install locales \
  && locale-gen en_US.UTF-8 \
  && dpkg-reconfigure locales \
  && echo "LC_ALL=en_US.UTF-8\nLANG=en_US.UTF-8\nLANGUAGE=en_US.UTF-8" > /etc/default/locale \
  && echo 'export LC_ALL=en_US.UTF-8' >> /root/.profile \
  && echo 'export LANG=en_US.UTF-8' >> /root/.profile \
  && echo 'export LANGUAGE=en_US.UTF-8' >> /root/.profile

ENV LC_ALL en_US.UTF-8
ENV LANG en_US.UTF-8
ENV LANGUAGE en_US.UTF-8

# Basic Linux tools
RUN apt-get -y --no-install-recommends install wget \
  vim \
  curl \
  sudo \
  unzip \
  zip \
  gnupg2 \
  jq \
  netcat-openbsd \
  bsdmainutils \
  libcurl4-gnutls-dev \
  libxml2-utils \
  libjpeg-dev \
  aspell \
  ghostscript \
  inkscape \
  build-essential \
  automake \
  autoconf \
  chrpath \
  libxft-dev \
  libfreetype6 \
  libfreetype6-dev \
  libfontconfig1 \
  libfontconfig1-dev \
  software-properties-common

# LaTeX
ENV TEXLIVE_YEAR 2024
RUN mkdir /tmp/texlive \
  && cd /tmp/texlive \
  && wget http://mirror.ctan.org/systems/texlive/tlnet/install-tl.zip \
  && unzip ./install-tl.zip -d install-tl \
  && cd install-tl/install-tl-* \
  && echo "selected_scheme scheme-medium" > p \
  && perl ./install-tl --profile=p \
  && ln -s $(ls /usr/local/texlive/${TEXLIVE_YEAR}/bin/) /usr/local/texlive/${TEXLIVE_YEAR}/bin/latest
ENV PATH "${PATH}:/usr/local/texlive/${TEXLIVE_YEAR}/bin/latest"
RUN echo "export PATH=\${PATH}:/usr/local/texlive/${TEXLIVE_YEAR}/bin/latest" >> /root/.profile \
  && tlmgr init-usertree \
  && tlmgr install texliveonfly \
  && pdflatex --version \
  && bash -c '[[ "$(pdflatex --version)" =~ "2.6" ]]' \
  && tlmgr install latexmk \
  && bash -c 'latexmk --version'

# CMake for C/C++ projects
RUN apt-get -y install cmake

# Docker cli
RUN mkdir -p /tmp/download \
  && curl -s -L "https://download.docker.com/linux/static/stable/x86_64/docker-18.06.3-ce.tgz" | tar -xz -C /tmp/download \
  && mv /tmp/download/docker/docker /usr/bin/ \
  && rm -rf /tmp/download

# Git 2.0
RUN add-apt-repository ppa:git-core/ppa \
  && apt-get update -y --fix-missing \
  && apt-get -y --no-install-recommends install git \
  && bash -c 'git --version'

# SSH Daemon
RUN apt-get -y install ssh \
  && mkdir /var/run/sshd \
  && chmod 0755 /var/run/sshd

# Ruby
RUN apt-get -y install ruby-dev libmagic-dev zlib1g-dev openssl \
  && gpg --keyserver keyserver.ubuntu.com --recv-keys 409B6B1796C275462A1703113804BB82D39DC0E3 7D2BAF1CF37B13E2069D6956105BD0E739499BDB \
  && curl -L https://get.rvm.io | sudo bash -s stable \
  && echo "source /usr/local/rvm/scripts/rvm && rvm use 3.2.2 && rvm default 3.2.2" >> /root/.profile \
  && bash -l -c ". /etc/profile.d/rvm.sh && rvm pkg install openssl" \
  && bash -l -c ". /etc/profile.d/rvm.sh && rvm install ruby-2.7.6 --with-openssl-dir=/usr/local/rvm/usr" \
  && bash -l -c ". /etc/profile.d/rvm.sh && rvm install ruby-3.2.2 --with-openssl-lib=/usr/lib --with-openssl-include=/usr/include" \
  && echo 'gem: --no-document' >> ~/.gemrc \
  && echo 'rvm_silence_path_mismatch_check_flag=1' >> ~/.rvmrc \
  && bash -l -c ". /etc/profile.d/rvm.sh \
    && rvm use 3.2.2 \
    && gem install bundler -v 2.3.26 \
    && gem install xcop -v 0.7.1 \
    && gem install pdd -v 0.23.1 \
    && gem install openssl -v 3.1.0"

# PHP
RUN LC_ALL=C.UTF-8 add-apt-repository ppa:ondrej/php \
  && apt-get update -y --fix-missing \
  && apt-get -y install php7.2 php-pear php7.2-curl php7.2-dev php7.2-gd php7.2-mbstring php7.2-zip php7.2-mysql php7.2-xml \
  && curl --silent --show-error https://getcomposer.org/installer | php \
  && mv composer.phar /usr/local/bin/composer \
  && bash -c 'php --version'

# Java
ENV MAVEN_OPTS "-Xmx1g"
ENV JAVA_OPTS "-Xmx1g"
ENV JAVA_HOME "/usr/lib/jvm/java-17"
RUN apt-get -y install ca-certificates openjdk-11-jdk openjdk-17-jdk \
  && update-java-alternatives --set $(ls /usr/lib/jvm | grep java-1.11) \
  && ln -s "/usr/lib/jvm/$(ls /usr/lib/jvm | grep java-1.11)" /usr/lib/jvm/java-11 \
  && ln -s "/usr/lib/jvm/$(ls /usr/lib/jvm | grep java-1.17)" /usr/lib/jvm/java-17 \
  && echo 'export JAVA_HOME=/usr/lib/jvm/java-11' >> /root/.profile \
  && bash -c '[[ "$(javac  --version)" =~ "11.0" ]]'

# QPDF
RUN cd /tmp \
  && git clone https://github.com/qpdf/qpdf \
  && cd qpdf \
  && git checkout v11.2.0 \
  && cmake -S . -B build -DCMAKE_BUILD_TYPE=RelWithDebInfo \
  && cmake --build build \
  && cmake --install build \
  && export LD_LIBRARY_PATH=/usr/local/lib \
  && ldconfig \
  && bash -c '[[ "$(qpdf --version)" =~ "11.2" ]]'

# S3cmd for AWS S3 integration
RUN apt-get -y install s3cmd

# Postgresql
RUN apt-get -y install postgresql-client postgresql \
  && bash -c 'psql --version'
USER postgres
RUN /etc/init.d/postgresql start \
  && psql --command "CREATE USER rultor WITH SUPERUSER PASSWORD 'rultor';" \
  && createdb -O rultor rultor
EXPOSE 5432
USER root
ENV PATH="${PATH}:/usr/lib/postgresql/14/bin"
RUN echo 'export PATH=${PATH}:/usr/lib/postgresql/14/bin' >> /root/.profile \
  && bash -c 'initdb --version'
# Postgresql service has to be started using `sudo /etc/init.d/postgresql start` in .rultor.yml

# Maven
ENV MAVEN_VERSION 3.9.6
ENV M2_HOME "/usr/local/apache-maven/apache-maven-${MAVEN_VERSION}"
RUN echo 'export M2_HOME=/usr/local/apache-maven/apache-maven-${MAVEN_VERSION}' >> /root/.profile \
  && wget --quiet "https://dlcdn.apache.org/maven/maven-3/${MAVEN_VERSION}/binaries/apache-maven-${MAVEN_VERSION}-bin.tar.gz" \
  && mkdir -p /usr/local/apache-maven \
  && mv "apache-maven-${MAVEN_VERSION}-bin.tar.gz" /usr/local/apache-maven \
  && tar xzvf "/usr/local/apache-maven/apache-maven-${MAVEN_VERSION}-bin.tar.gz" -C /usr/local/apache-maven/ \
  && update-alternatives --install /usr/bin/mvn mvn "${M2_HOME}/bin/mvn" 1 \
  && update-alternatives --config mvn \
  && mvn -version \
  && bash -c '[[ "$(mvn --version)" =~ "${MAVEN_VERSION}" ]]'
COPY settings.xml /root/.m2/settings.xml

# Python3
RUN add-apt-repository -y ppa:deadsnakes/ppa \
  && apt-get update -y --fix-missing \
  && apt-get -y install libpq-dev libssl-dev openssl libffi-dev python3.7 python3-pip python3.7-dev \
  && ln -s $(which python3) /usr/bin/python \
  && bash -c 'python --version' \
  && pip3 install -Iv --upgrade pip \
  && bash -c 'pip --version'

# Pygments
RUN apt-get -y install python3-pygments \
  && pip3 install -Iv pygments

# NodeJS
RUN rm -rf /usr/lib/node_modules \
  && curl -sL https://deb.nodesource.com/setup_18.x -o /tmp/nodesource_setup.sh \
  && bash /tmp/nodesource_setup.sh \
  && apt-get -y install nodejs \
  && bash -c 'node --version' \
  && bash -c 'npm --version'

# Rust and Cargo
ENV PATH="${PATH}:${HOME}/.cargo/bin"
RUN curl https://sh.rustup.rs -sSf | bash -s -- -y \
  && echo 'export PATH=${PATH}:${HOME}/.cargo/bin' >> /root/.profile \
  && ${HOME}/.cargo/bin/rustup toolchain install stable \
  && bash -c '"${HOME}/.cargo/bin/cargo" --version'

# Go
RUN apt-get update \
  && apt-get install -y golang \
  && bash -c 'go version'

# Clean up
RUN rm -rf /tmp/* \
  /root/.ssh \
  /root/.cache \
  /root/.wget-hsts \
  /root/.gnupg

ENTRYPOINT ["/bin/bash", "--login", "-c"]
