FROM alpine:3.5

LABEL MAINTAINERS="Guillaume Scheibel <guillaume.scheibel@gmail.com>, Damien DUPORTAL <damien.duportal@gmail.com>"

ENV JAVA_HOME=/usr/lib/jvm/default-jvm \
  ASCIIDOCTOR_VERSION="1.5.5"

RUN apk --update --no-cache add \
    asciidoctor="${ASCIIDOCTOR_VERSION}-r0" \
    bash \
    build-base \
    curl \
    ca-certificates \
    graphviz \
    jpeg \
    jpeg-dev \
    patch \
    python2 \
    python2-dev \
    py-pip \
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
  && pip install --no-cache-dir --upgrade pip \
  && pip install --no-cache-dir 'blockdiag[pdf]' \
  && pip install --no-cache-dir seqdiag \
  && pip install --no-cache-dir actdiag \
  && pip install --no-cache-dir nwdiag \
  && apk del -r \
    build-base \
    jpeg-dev \
    python2-dev \
    unzip \
    zip \
    zlib-dev \
  && rm -rf /var/cache/apk/* /root/.gradle/caches/*


WORKDIR /documents
VOLUME /documents

CMD ["/bin/bash"]
