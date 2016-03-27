FROM fedora

MAINTAINER Guillaume Scheibel <guillaume.scheibel@gmail.com>

ENV JAVA_HOME /jdk1.8.0_20
ENV PATH $PATH:$JAVA_HOME/bin:/fopub/bin
ENV BACKENDS /asciidoctor-backends
ENV GVM_AUTO_ANSWER true
ENV ASCIIDOCTOR_VERSION "1.5.4"

RUN dnf install -y tar \
    make \
    gcc \
    ruby \
    ruby-devel \
    rubygems \
    graphviz \
    rubygem-nokogiri \
    unzip \
    findutils \
    which \
    wget \
    python-devel \
    zlib-devel \
    libjpeg-devel \
    redhat-rpm-config \
    patch \
  && dnf clean packages \
  && (curl -s -k -L -C - -b "oraclelicense=accept-securebackup-cookie" http://download.oracle.com/otn-pub/java/jdk/8u20-b26/jdk-8u20-linux-x64.tar.gz | tar xfz -) \
  && mkdir /fopub \
  && curl -L https://api.github.com/repos/asciidoctor/asciidoctor-fopub/tarball | tar xzf - -C /fopub/ --strip-components=1 \
  && touch empty.xml \
  && fopub empty.xml \
  && rm empty.xml \
  && gem install --no-ri --no-rdoc asciidoctor --version $ASCIIDOCTOR_VERSION \
  && gem install --no-ri --no-rdoc asciidoctor-diagram \
  && gem install --no-ri --no-rdoc asciidoctor-epub3 --version 1.5.0.alpha.6 \
  && gem install --no-ri --no-rdoc asciidoctor-pdf --version 1.5.0.alpha.11 \
  && gem install --no-ri --no-rdoc asciidoctor-confluence \
  && gem install --no-ri --no-rdoc coderay pygments.rb thread_safe epubcheck kindlegen \
  && gem install --no-ri --no-rdoc slim \
  && gem install --no-ri --no-rdoc haml tilt \
  && mkdir $BACKENDS \
  && (curl -LkSs https://api.github.com/repos/asciidoctor/asciidoctor-backends/tarball | tar xfz - -C $BACKENDS --strip-components=1) \
  && wget https://bitbucket.org/pypa/setuptools/raw/bootstrap/ez_setup.py -O - | python \
  && easy_install "blockdiag[pdf]" \
  && easy_install seqdiag \
  && easy_install actdiag \
  && easy_install nwdiag \
  && (curl -s get.sdkman.io | bash) \
  && /bin/bash -c "source /root/.sdkman/bin/sdkman-init.sh" \
  && /bin/bash -c "echo sdkman_auto_answer=true > ~/.sdkman/etc/config" \
  && /bin/bash -c -l "sdk install lazybones"

WORKDIR /documents
VOLUME /documents

CMD ["/bin/bash"]
