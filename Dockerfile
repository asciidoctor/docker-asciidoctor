FROM alpine:3.5

LABEL MAINTAINER="Guillaume Scheibel <guillaume.scheibel@gmail.com>"
LABEL MAINTAINER="Damien DUPORTAL <damien.duportal@gmail.com>"

ENV JAVA_HOME=/usr/lib/jvm/default-jvm \
  PATH=${PATH}:${JAVA_HOME}/bin:/fopub/bin \
  BACKENDS=/asciidoctor-backends \
  GVM_AUTO_ANSWER=true \
  ASCIIDOCTOR_VERSION="1.5.5"

RUN apk --update --no-cache add \
    asciidoctor \
    bash \
    build-base \
    curl \
    graphviz \
    jpeg \
    jpeg-dev \
    openjdk8 \
    patch \
    python2 \
    python2-dev \
    py-pillow \
    py-setuptools \
    ruby \
    ruby-dev \
    tar \
    ttf-liberation \
    unzip \
    findutils \
    which \
    wget \
    zip \
    zlib-dev \
  && mkdir /fopub \
  && curl -L -s https://api.github.com/repos/asciidoctor/asciidoctor-fopub/tarball | tar xzf - -C /fopub/ --strip-components=1 \
  && gem install --no-ri --no-rdoc asciidoctor-diagram \
  && gem install --no-ri --no-rdoc asciidoctor-epub3 --version 1.5.0.alpha.6 \
  && gem install --no-ri --no-rdoc asciidoctor-revealjs \
  && gem install --no-ri --no-rdoc rake \
  && gem install --no-ri --no-rdoc epubcheck --version 3.0.1 \
  && gem install --no-ri --no-rdoc kindlegen --version 3.0.3 \
  && gem install --no-ri --no-rdoc prawn --version 2.1.0 \
  && gem install --no-ri --no-rdoc asciidoctor-pdf --version 1.5.0.alpha.14 \
  && gem install --no-ri --no-rdoc asciidoctor-confluence \
  && gem install --no-ri --no-rdoc rouge coderay pygments.rb thread_safe \
  && gem install --no-ri --no-rdoc slim haml tilt \
  && mkdir "${BACKENDS}" \
  && (curl -LkSs https://api.github.com/repos/asciidoctor/asciidoctor-backends/tarball | tar xfz - -C "${BACKENDS}" --strip-components=1) \
  && ln -s /usr/bin/easy_install-2.7 /usr/local/bin/easy_install \
  && easy_install 'blockdiag[pdf]' \
  && easy_install seqdiag \
  && easy_install actdiag \
  && easy_install nwdiag \
  && (curl -s get.sdkman.io | bash) \
  && bash -c "source /root/.sdkman/bin/sdkman-init.sh" \
  && bash -c "echo sdkman_auto_answer=true > ~/.sdkman/etc/config" \
  && bash -c -l "sdk install lazybones" \
  && apk del -r \
    build-base \
    curl \
    jpeg-dev \
    python2-dev \
    unzip \
    zip \
    zlib-dev \
  && rm -rf /var/cache/apk/* /root/.gradle/caches/*


WORKDIR /documents
VOLUME /documents

CMD ["/bin/bash"]
