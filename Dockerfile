# Golang version defined in https://github.com/kaishuu0123/erd-go/blob/${ERD_VERSION}/go.mod#L3
ARG ERD_GOLANG_BUILDER_TAG=1.25-alpine3.22
ARG A2S_GOLANG_BUILDER_TAG=1.25-alpine3.22
ARG alpine_version=3.22.1
FROM alpine:${alpine_version} AS base

# # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
# Minimal image with asciidoctor
# # # # # # # # # # # # # # # # # # # # # # # # # # # # # #

FROM base AS main-minimal

LABEL maintainers="Guillaume Scheibel <guillaume.scheibel@gmail.com>, Damien DUPORTAL <damien.duportal@gmail.com>"
LABEL org.opencontainers.image.source="https://github.com/asciidoctor/docker-asciidoctor"

ARG asciidoctor_version=2.0.23
ARG asciidoctor_pdf_version=2.3.20

ENV ASCIIDOCTOR_VERSION=${asciidoctor_version} \
  ASCIIDOCTOR_PDF_VERSION=${asciidoctor_pdf_version}
## Always use the latest Ruby version available for the current Alpine distribution
# hadolint ignore=DL3018
RUN apk add --no-cache ruby \
  && gem install --no-document \
  "asciidoctor:${ASCIIDOCTOR_VERSION}" \
  "asciidoctor-pdf:${ASCIIDOCTOR_PDF_VERSION}"

# # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
# Install erd-go (https://github.com/kaishuu0123/erd-go) as replacement for erd (https://github.com/BurntSushi/erd)
# # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
FROM golang:${ERD_GOLANG_BUILDER_TAG} AS erd-builder
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

# # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
# Install ASCIIToSVG https://github.com/asciitosvg/asciitosvg
# # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
FROM golang:${A2S_GOLANG_BUILDER_TAG} AS a2s-builder
# Expects a git reference as there are no tags in the A2S repository
ARG A2S_VERSION=ca82a5c
RUN GOBIN=/app go install github.com/asciitosvg/asciitosvg/cmd/a2s@"${A2S_VERSION}"

# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # \
# Final image
# # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
FROM main-minimal AS main
SHELL ["/bin/ash", "-eo", "pipefail", "-c"]
LABEL maintainers="Guillaume Scheibel <guillaume.scheibel@gmail.com>, Damien DUPORTAL <damien.duportal@gmail.com>"

ARG TARGETARCH

## Always use the latest dependencies versions available for the current Alpine distribution
# hadolint ignore=DL3018
RUN apk add --no-cache \
  bash \
  curl \
  ca-certificates \
  findutils \
  font-bakoma-ttf \
  git \
  gnuplot \
  graphviz \
  inotify-tools \
  make \
  openjdk21-jre \
  python3 \
  py3-cairo \
  py3-setuptools \
  ruby-bigdecimal \
  ruby-nokogiri \
  # Required for asciidoctor-epub
  ruby-ffi \
  ruby-mathematical \
  ruby-rake \
  texlive \
  texmf-dist-latexextra \
  ttf-liberation \
  ttf-dejavu \
  tzdata \
  unzip \
  which \
  font-noto-cjk \
  lilypond \
  && apk add --no-cache -X http://dl-cdn.alpinelinux.org/alpine/edge/testing \
  pdf2svg

ARG asciidoctor_confluence_version=0.0.2
ARG asciidoctor_diagram_version=3.0.1
ARG asciidoctor_epub3_version=2.3.0
ARG asciidoctor_fb2_version=0.8.0
ARG asciidoctor_mathematical_version=0.3.5
ARG asciidoctor_revealjs_version=5.2.0
ARG kramdown_asciidoc_version=2.1.1
ARG asciidoctor_bibtex_version=0.9.0
ARG asciidoctor_kroki_version=0.10.0
ARG asciidoctor_reducer_version=1.0.2
ARG barby_version=0.6.8
ARG rqrcode_version=2.2.0
ARG chunky_png_version=1.4.0

ENV ASCIIDOCTOR_CONFLUENCE_VERSION=${asciidoctor_confluence_version} \
  ASCIIDOCTOR_DIAGRAM_VERSION=${asciidoctor_diagram_version} \
  ASCIIDOCTOR_EPUB3_VERSION=${asciidoctor_epub3_version} \
  ASCIIDOCTOR_FB2_VERSION=${asciidoctor_fb2_version} \
  ASCIIDOCTOR_MATHEMATICAL_VERSION=${asciidoctor_mathematical_version} \
  ASCIIDOCTOR_REVEALJS_VERSION=${asciidoctor_revealjs_version} \
  KRAMDOWN_ASCIIDOC_VERSION=${kramdown_asciidoc_version} \
  ASCIIDOCTOR_BIBTEX_VERSION=${asciidoctor_bibtex_version} \
  ASCIIDOCTOR_KROKI_VERSION=${asciidoctor_kroki_version} \
  ASCIIDOCTOR_REDUCER_VERSION=${asciidoctor_reducer_version} \
  BARBY_VERSION=${barby_version} \
  RQRCODE_VERSION=${rqrcode_version} \
  CHUNKY_PNG_VERSION=${chunky_png_version}

## Always use the latest dependencies versions available for the current Alpine distribution
# hadolint ignore=DL3018,DL3028
RUN apk add --no-cache --virtual .rubymakedepends \
  build-base \
  libxml2-dev \
  ruby-dev \
  && gem install --no-document \
  "asciidoctor-confluence:${ASCIIDOCTOR_CONFLUENCE_VERSION}" \
  "asciidoctor-diagram:${ASCIIDOCTOR_DIAGRAM_VERSION}" \
  # TODO: track with updatecli
  "asciidoctor-diagram-ditaamini:1.0.3" `# Used by asciidoctor-diagram` \
  # TODO: track with updatecli
  "asciidoctor-diagram-plantuml:1.2025.2" `# Used by asciidoctor-diagram` \
  "asciidoctor-epub3:${ASCIIDOCTOR_EPUB3_VERSION}" \
  "asciidoctor-fb2:${ASCIIDOCTOR_FB2_VERSION}" \
  "asciidoctor-mathematical:${ASCIIDOCTOR_MATHEMATICAL_VERSION}" \
  asciimath \
  "asciidoctor-revealjs:${ASCIIDOCTOR_REVEALJS_VERSION}" \
  coderay \
  epubcheck-ruby \
  haml \
  "kramdown-asciidoc:${KRAMDOWN_ASCIIDOC_VERSION}" \
  pygments.rb \
  rouge \
  slim \
  thread_safe \
  tilt \
  text-hyphen \
  rghost \
  "asciidoctor-bibtex:${ASCIIDOCTOR_BIBTEX_VERSION}" \
  "asciidoctor-kroki:${ASCIIDOCTOR_KROKI_VERSION}" \
  "asciidoctor-reducer:${ASCIIDOCTOR_REDUCER_VERSION}" \
  "barby:${BARBY_VERSION}" \
  "rqrcode:${RQRCODE_VERSION}" \
  "chunky_png:${CHUNKY_PNG_VERSION}" \
  && apk del -r --no-cache .rubymakedepends

# Specific pipx environement variables to ensure binaries (and docs, etc.) are available for all users
# See https://github.com/pypa/pipx/blob/main/docs/installation.md#installation-options
ENV PIPX_HOME=/opt/pipx
ENV PIPX_BIN_DIR=/usr/local/bin
ENV PIPX_MAN_DIR=/usr/local/share/man

## Always use the latest dependencies versions available for the current Alpine distribution
# hadolint ignore=DL3018,DL3013
RUN apk add --no-cache \
  pipx \
  py3-pip \
  && apk add --no-cache --virtual .pythonmakedepends \
  build-base \
  freetype-dev \
  python3-dev \
  jpeg-dev \
  && for pipx_app in \
  actdiag \
  'blockdiag[pdf]' \
  nwdiag \
  seqdiag \
  ;do pipx install --system-site-packages --pip-args='--no-cache-dir' "${pipx_app}"; \
  # Pin pillow to 9.5.0 as per https://github.com/asciidoctor/docker-asciidoctor/pull/403#issuecomment-1894323894
  pipx runpip "$(echo "$pipx_app" | cut -d'[' -f1)" install Pillow==9.5.0; done \
  && apk del -r --no-cache .pythonmakedepends

COPY --from=a2s-builder /app/a2s /usr/local/bin/
COPY --from=erd-builder /app/erd-go /usr/local/bin/
# for backward compatibility
RUN ln -snf /usr/local/bin/erd-go /usr/local/bin/erd

WORKDIR /documents
VOLUME /documents

CMD ["/bin/bash"]
