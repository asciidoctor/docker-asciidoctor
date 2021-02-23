FROM alpine:3.13 AS base

ARG asciidoctor_version=2.0.12
ARG asciidoctor_confluence_version=0.0.2
ARG asciidoctor_pdf_version=1.5.4
ARG asciidoctor_diagram_version=2.1.0
ARG asciidoctor_epub3_version=1.5.0.alpha.19
ARG asciidoctor_mathematical_version=0.3.5
ARG asciidoctor_revealjs_version=4.1.0
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
  ASCIIDOCTOR_BIBTEX_VERSION=${asciidoctor_bibtex_version}

# # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
# Ruby build for: asciidoctor, asciidoctor-pdf, and all kinds of associated tools
# # # # # # # # # # # # # # # # # # # # # # # # # # # # # #

FROM base AS build-ruby
RUN echo "building Ruby dependencies" # keep here to help --cache-from along

RUN apk add --no-cache \
      build-base \
      libxml2-dev \
      ruby-dev \
      cmake \
      bison \
      flex \
      python3 \
      glib-dev \
      cairo-dev \
      pango-dev \
      gdk-pixbuf-dev

RUN gem install --no-document \
      --install-dir /usr/lib/ruby/gems \
      --bindir      /usr/lib/ruby/bin \
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
      "asciidoctor-bibtex:${ASCIIDOCTOR_BIBTEX_VERSION}"

RUN rm -rf /usr/lib/ruby/gems/cache/*

# # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
# Haskell build for: erd
# # # # # # # # # # # # # # # # # # # # # # # # # # # # # #

FROM base AS build-haskell
RUN echo "building Haskell dependencies" # keep here to help --cache-from along

RUN apk add --no-cache \
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
    zlib-dev

RUN cabal v2-update \
 && cabal v2-install erd

# # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
# Final image
# # # # # # # # # # # # # # # # # # # # # # # # # # # # # #

FROM base AS main
RUN echo "building main image" # keep here to help --cache-from along

LABEL MAINTAINERS="Guillaume Scheibel <guillaume.scheibel@gmail.com>, Damien DUPORTAL <damien.duportal@gmail.com>"

# Installing package required for the runtime of
# any of the asciidoctor-* functionnalities
RUN apk add --no-cache \
    bash \
    curl \
    ca-certificates \
    findutils \
    font-bakoma-ttf \
    git \
    gmp \
    graphviz \
    inotify-tools \
    libffi \
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

# --target=XYZ --> XYZ/bin --> ln -s XYZ/bin/* /bin/
# COPY --from=build-python    /usr/local/lib/python3.9/site-packages /usr/local/lib/python3.9/site-packages

COPY --from=build-ruby    /usr/lib/ruby/gems/     /usr/lib/ruby/gems/
COPY --from=build-ruby    /usr/lib/ruby/bin/      /bin/
ENV GEM_HOME=/usr/lib/ruby/gems

COPY --from=build-haskell root/.cabal/bin/erd     /bin/

WORKDIR /documents
VOLUME /documents

CMD ["/bin/bash"]
