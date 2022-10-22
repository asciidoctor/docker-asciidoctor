ARG alpine_version=3.16.2
FROM alpine:${alpine_version} AS base

ARG asciidoctor_version=2.0.18
ARG asciidoctor_confluence_version=0.0.2
ARG asciidoctor_pdf_version=2.3.3
ARG asciidoctor_diagram_version=2.2.1
ARG asciidoctor_epub3_version=1.5.1
ARG asciidoctor_fb2_version=0.5.1
ARG asciidoctor_mathematical_version=0.3.5
ARG asciidoctor_revealjs_version=4.1.0
ARG kramdown_asciidoc_version=2.1.0
ARG asciidoctor_bibtex_version=0.8.0
ARG asciidoctor_kroki_version=0.7.0
ARG asciidoctor_reducer_version=1.0.2

ENV ASCIIDOCTOR_VERSION=${asciidoctor_version} \
  ASCIIDOCTOR_CONFLUENCE_VERSION=${asciidoctor_confluence_version} \
  ASCIIDOCTOR_PDF_VERSION=${asciidoctor_pdf_version} \
  ASCIIDOCTOR_DIAGRAM_VERSION=${asciidoctor_diagram_version} \
  ASCIIDOCTOR_EPUB3_VERSION=${asciidoctor_epub3_version} \
  ASCIIDOCTOR_FB2_VERSION=${asciidoctor_fb2_version} \
  ASCIIDOCTOR_MATHEMATICAL_VERSION=${asciidoctor_mathematical_version} \
  ASCIIDOCTOR_REVEALJS_VERSION=${asciidoctor_revealjs_version} \
  KRAMDOWN_ASCIIDOC_VERSION=${kramdown_asciidoc_version} \
  ASCIIDOCTOR_BIBTEX_VERSION=${asciidoctor_bibtex_version} \
  ASCIIDOCTOR_KROKI_VERSION=${asciidoctor_kroki_version} \
  ASCIIDOCTOR_REDUCER_VERSION=${asciidoctor_reducer_version}

# # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
# Minimal image with asciidoctor
# # # # # # # # # # # # # # # # # # # # # # # # # # # # # #

FROM base AS main-minimal
RUN echo "assemble minimal main image" # keep here to help --cache-from along

LABEL maintainers="Guillaume Scheibel <guillaume.scheibel@gmail.com>, Damien DUPORTAL <damien.duportal@gmail.com>"

## Always use the latest Ruby version available for the current Alpine distribution
# hadolint ignore=DL3018
RUN apk add --no-cache ruby \
  && gem install --no-document \
  "asciidoctor:${ASCIIDOCTOR_VERSION}" \
  "asciidoctor-pdf:${ASCIIDOCTOR_PDF_VERSION}"

# # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
# Haskell build for: erd
# # # # # # # # # # # # # # # # # # # # # # # # # # # # # #

FROM base AS build-haskell

## Always use the latest Cabal (and dependencies) versions available for the current Alpine distribution
# hadolint ignore=DL3018
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
  zlib-dev \
  && cabal v2-update \
  && cabal v2-install erd

# # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
# Final image
# # # # # # # # # # # # # # # # # # # # # # # # # # # # # #

FROM main-minimal AS main
RUN echo "assemble comprehensive main image" # keep here to help --cache-from along

LABEL maintainers="Guillaume Scheibel <guillaume.scheibel@gmail.com>, Damien DUPORTAL <damien.duportal@gmail.com>"

## Always use the latest dependencies versions available for the current Alpine distribution
# hadolint ignore=DL3018,DL3013,DL3028
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
  openjdk17-jre \
  python3 \
  py3-pillow \
  py3-setuptools \
  ruby-bigdecimal \
  ruby-mathematical \
  ruby-rake \
  ttf-liberation \
  ttf-dejavu \
  tzdata \
  unzip \
  which \
  font-noto-cjk \
  && apk add --no-cache --virtual .rubymakedepends \
  build-base \
  libxml2-dev \
  ruby-dev \
  && gem install --no-document \
  "asciidoctor-confluence:${ASCIIDOCTOR_CONFLUENCE_VERSION}" \
  "asciidoctor-diagram:${ASCIIDOCTOR_DIAGRAM_VERSION}" \
  "asciidoctor-epub3:${ASCIIDOCTOR_EPUB3_VERSION}" \
  "asciidoctor-fb2:${ASCIIDOCTOR_FB2_VERSION}" \
  "asciidoctor-mathematical:${ASCIIDOCTOR_MATHEMATICAL_VERSION}" \
  asciimath \
  "asciidoctor-revealjs:${ASCIIDOCTOR_REVEALJS_VERSION}" \
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
  "asciidoctor-kroki:${ASCIIDOCTOR_KROKI_VERSION}" \
  "asciidoctor-reducer:${ASCIIDOCTOR_REDUCER_VERSION}" \
  && apk del -r --no-cache .rubymakedepends \
  && apk add --no-cache --virtual .pythonmakedepends \
  build-base \
  freetype-dev \
  python3-dev \
  py3-pip \
  && pip3 install --no-cache-dir \
  actdiag \
  'blockdiag[pdf]' \
  nwdiag \
  seqdiag \
  && apk del -r --no-cache .pythonmakedepends

COPY --from=build-haskell root/.cabal/bin/erd     /bin/

WORKDIR /documents
VOLUME /documents

CMD ["/bin/bash"]
