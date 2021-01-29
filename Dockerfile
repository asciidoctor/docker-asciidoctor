FROM alpine:3.13

LABEL MAINTAINERS="Guillaume Scheibel <guillaume.scheibel@gmail.com>, Damien DUPORTAL <damien.duportal@gmail.com>"

ARG asciidoctor_version=2.0.12
ARG asciidoctor_confluence_version=0.0.2
ARG asciidoctor_pdf_version=1.5.4
ARG asciidoctor_diagram_version=2.1.0
ARG asciidoctor_epub3_version=1.5.0.alpha.19
ARG asciidoctor_mathematical_version=0.3.4
ARG asciidoctor_revealjs_version=4.0.1
ARG kramdown_asciidoc_version=1.0.1
ARG asciidoctor_bibtex_version=0.8.0

ENV ASCIIDOCTOR_VERSION=${asciidoctor_version} \
  ASCIIDOCTOR_CONFLUENCE_VERSION=${asciidoctor_confluence_version} \
  ASCIIDOCTOR_PDF_VERSION=${asciidoctor_pdf_version} \
  ASCIIDOCTOR_DIAGRAM_VERSION=${asciidoctor_diagram_version} \
  ASCIIDOCTOR_EPUB3_VERSION=${asciidoctor_epub3_version} \
  ASCIIDOCTOR_MATHEMATICAL_VERSION=${asciidoctor_mathematical_version} \
  ASCIIDOCTOR_REVEALJS_VERSION=${asciidoctor_revealjs_version} \
  KRAMDOWN_ASCIIDOC_VERSION=${kramdown_asciidoc_version} \
  ASCIIDOCTOR_BIBTEX_VERSION=${asciidoctor_bibtex_version} \
  PATH="/root/.cabal/bin/:${PATH}"

# Installing package required for the runtime of
# any of the asciidoctor-* functionnalities
RUN apk add --no-cache \
    bash \
    curl \
    ca-certificates \
    findutils \
    font-bakoma-ttf \
    git \
    graphviz \
    inotify-tools \
    make \
    openjdk8-jre \
    python3 \
    py3-pillow \
    py3-setuptools \
    ruby \
    ruby-bigdecimal \
    ruby-mathematical \
    ruby-rake \
    ttf-liberation \
    ttf-dejavu \
    tzdata \
    unzip \
    which

# Installing Ruby Gems needed in the image
# including asciidoctor itself
RUN apk add --no-cache --virtual .rubymakedepends \
    build-base \
    libxml2-dev \
    ruby-dev \
  && gem install --no-document \
    "asciidoctor:${ASCIIDOCTOR_VERSION}" \
    "asciidoctor-confluence:${ASCIIDOCTOR_CONFLUENCE_VERSION}" \
    "asciidoctor-diagram:${ASCIIDOCTOR_DIAGRAM_VERSION}" \
    "asciidoctor-epub3:${ASCIIDOCTOR_EPUB3_VERSION}" \
    "asciidoctor-mathematical:${ASCIIDOCTOR_MATHEMATICAL_VERSION}" \
    asciimath \
    "asciidoctor-pdf:${ASCIIDOCTOR_PDF_VERSION}" \
    "asciidoctor-revealjs:${ASCIIDOCTOR_REVEALJS_VERSION}" \
    bigdecimal \
    coderay \
    epubcheck-ruby:4.2.4.0 \
    haml \
    "kramdown-asciidoc:${KRAMDOWN_ASCIIDOC_VERSION}" \
    pygments.rb \
    rouge \
    slim \
    thread_safe \
    tilt \
    text-hyphen \
    "asciidoctor-bibtex:${ASCIIDOCTOR_BIBTEX_VERSION}" \
  && apk del -r --no-cache .rubymakedepends

# Installing Python dependencies for additional
# functionnalities as diagrams or syntax highligthing
RUN apk add --no-cache --virtual .pythonmakedepends \
    build-base \
    python3-dev \
    py3-pip \
  && pip3 install --no-cache-dir \
    actdiag \
    'blockdiag[pdf]' \
    nwdiag \
    seqdiag \
  && apk del -r --no-cache .pythonmakedepends

# ERD
RUN apk add --no-cache --virtual .haskellmakedepends \
    alpine-sdk \
    cabal \
    ghc-dev \
    ghc \
    gmp-dev \
    gnupg \
    libffi-dev \
    linux-headers \
    perl-utils \
    wget \
    xz \
    zlib-dev \
  && cabal v2-update \
  && cabal v2-install erd \
  && apk del -r --no-cache .haskellmakedepends

WORKDIR /documents
VOLUME /documents

CMD ["/bin/bash"]
