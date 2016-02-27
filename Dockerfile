FROM alpine:3.3

MAINTAINER Guillaume Scheibel <guillaume.scheibel@gmail.com>
MAINTAINER Damien DUPORTAL <damien.duportal@gmail.com>

ENV JAVA_HOME /usr/lib/jvm/default-jvm
ENV PATH ${PATH}:${JAVA_HOME}/bin:/fopub/bin
ENV BACKENDS /asciidoctor-backends
ENV GVM_AUTO_ANSWER true
ENV ASCIIDOCTOR_VERSION "1.5.4"

RUN apk --update add \
    bash \
    build-base \
    curl \
    graphviz \
    openjdk8 \
    python \
    python-dev \
    py-pillow \
    ruby \
    ruby-dev \
    ruby-nokogiri \
    tar \
    ttf-liberation \
    unzip \
    zlib \
  && mkdir /fopub \
  && curl -L -s https://api.github.com/repos/asciidoctor/asciidoctor-fopub/tarball | tar xzf - -C /fopub/ --strip-components=1 \
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
  && (curl -LkSs https://api.github.com/repos/asciidoctor/asciidoctor-reveal.js/tarball | tar xfz - -C /asciidoctor-backends/slim/revealjs/ --strip-components=3) \
  && curl -L -s https://bitbucket.org/pypa/setuptools/raw/bootstrap/ez_setup.py | python \
  && easy_install "blockdiag[pdf]" \
  && easy_install seqdiag \
  && easy_install actdiag \
  && easy_install nwdiag \
  && (curl -s get.sdkman.io | bash) \
  && /bin/bash -c "source /root/.sdkman/bin/sdkman-init.sh" \
  && /bin/bash -c "echo sdkman_auto_answer=true > ~/.sdkman/etc/config" \
  && /bin/bash -c -l "sdk install lazybones" \
  && apk del -r \
    build-base \
    curl \
    python-dev \
    ruby-dev \
    unzip \
  && rm -rf /var/cache/apk/*

RUN rm /asciidoctor-backends/slim/revealjs/README.adoc
RUN rm /asciidoctor-backends/slim/dzslides/README.adoc

WORKDIR /documents
VOLUME /documents

CMD ["/bin/bash"]
