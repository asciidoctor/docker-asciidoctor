# Golang version defined in https://github.com/kaishuu0123/erd-go/blob/${ERD_VERSION}/go.mod#L3
ARG ERD_GOLANG_VERSION=1.15
ARG alpine_version=3.17.2
FROM alpine:${alpine_version} AS base

ARG asciidoctor_version=2.0.18
ARG asciidoctor_confluence_version=0.0.2
ARG asciidoctor_pdf_version=2.3.4
ARG asciidoctor_diagram_version=2.2.5
ARG asciidoctor_epub3_version=1.5.1
ARG asciidoctor_fb2_version=0.7.0
ARG asciidoctor_mathematical_version=0.3.5
ARG asciidoctor_revealjs_version=4.1.0
ARG kramdown_asciidoc_version=2.1.0
ARG asciidoctor_bibtex_version=0.8.0
ARG asciidoctor_kroki_version=0.8.0
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
LABEL org.opencontainers.image.source="https://github.com/asciidoctor/docker-asciidoctor"

## Always use the latest Ruby version available for the current Alpine distribution
# hadolint ignore=DL3018
RUN apk add --no-cache ruby \
  && gem install --no-document \
  "asciidoctor:${ASCIIDOCTOR_VERSION}" \
  "asciidoctor-pdf:${ASCIIDOCTOR_PDF_VERSION}"

# # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
# Install erd-go (https://github.com/kaishuu0123/erd-go) as replacement for erd (https://github.com/BurntSushi/erd)
# # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
FROM golang:${ERD_GOLANG_VERSION}-alpine as erd-builder
ARG ERD_VERSION=v2.0.0
## Always use the latest git package
# go install or go get cannot be used the go.mod syntax of erd-go is not following the Golang semver properties,
# leading to errors whatever method is used.
# This fixes it by using a go build method to generate the binary instead.
# hadolint ignore=DL3018
RUN apk add --no-cache git \
  && git clone https://github.com/kaishuu0123/erd-go -b "${ERD_VERSION}" /app
WORKDIR /app
RUN CGO_ENABLED=0 GOOS=linux go build

# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # \
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

COPY --from=erd-builder /app/erd-go /usr/local/bin/
# for backward compatibility
RUN ln -snf /usr/local/bin/erd-go /usr/local/bin/erd

WORKDIR /documents
VOLUME /documents

CMD ["/bin/bash"]
