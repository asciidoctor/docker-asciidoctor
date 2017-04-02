FROM alpine:3.5

LABEL MAINTAINERS="Guillaume Scheibel <guillaume.scheibel@gmail.com>, Damien DUPORTAL <damien.duportal@gmail.com>"

ENV ASCIIDOCTOR_VERSION="1.5.5"

ADD https://alpine.geeknet.cz/keys/jakub%40jirutka.cz-56d0d9fd.rsa.pub /etc/apk/keys/

RUN apk --update --no-cache add \
    asciidoctor="${ASCIIDOCTOR_VERSION}-r0" \
    bash \
    build-base \
    curl \
    ca-certificates \
    libxml2-dev \
    python2 python2-dev \
    py2-pip \
    py2-pillow \
    ruby \
    ruby-dev \
    ttf-liberation \
    unzip \
    findutils \
    which \
  && apk --repository 'https://alpine.geeknet.cz/packages/v3.5/backports' --no-cache add \
    lasem \
    ruby-mathematical \
    ruby-pygments \
  && ln -s /usr/lib/liblasem-0.4.so.4 /usr/lib/liblasem.so \
  && gem install --no-document prawn --version 2.1.0 \
  && gem install --no-document asciidoctor-epub3 --version 1.5.0.alpha.6 \
  && gem install --no-document asciidoctor-pdf --version 1.5.0.alpha.14 \
  && gem install --no-document epubcheck --version 3.0.1 \
  && gem install --no-document kindlegen --version 3.0.3 \
  && gem install --no-document asciidoctor-revealjs \
  && gem install --no-document asciidoctor-diagram \
  && gem install --no-document asciidoctor-confluence \
  && gem install --no-document asciidoctor-mathematical \
  && gem install --no-document rake rouge coderay thread_safe slim haml tilt \
  && pip install --no-cache-dir --upgrade pip \
  && pip install --no-cache-dir seqdiag actdiag nwdiag 'blockdiag[pdf]' \
  && apk del -r --no-cache \
    build-base \
    libxml2-dev \
    python2-dev

WORKDIR /documents
VOLUME /documents

CMD ["/bin/bash"]
