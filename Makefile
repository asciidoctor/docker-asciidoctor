
DOCKER_IMAGE_NAME ?= docker-asciidoctor
DOCKERHUB_USERNAME ?= asciidoctor
CURRENT_GIT_REF ?= $(shell git rev-parse --abbrev-ref HEAD) # Default to current branch
DOCKER_IMAGE_TAG ?= $(shell echo $(CURRENT_GIT_REF) | sed 's/\//-/' )
DOCKER_IMAGE_NAME_TO_TEST ?= $(DOCKERHUB_USERNAME)/$(DOCKER_IMAGE_NAME):$(DOCKER_IMAGE_TAG)
ASCIIDOCTOR_VERSION ?= 2.0.10
ASCIIDOCTOR_CONFLUENCE_VERSION ?= 0.0.2
ASCIIDOCTOR_PDF_VERSION ?= 1.5.0
ASCIIDOCTOR_DIAGRAM_VERSION ?= 2.0.1
ASCIIDOCTOR_EPUB3_VERSION ?= 1.5.0.alpha.12
ASCIIDOCTOR_MATHEMATICAL_VERSION ?= 0.3.1
ASCIIDOCTOR_REVEALJS_VERSION ?= 3.1.0
KRAMDOWN_ASCIIDOC_VERSION ?= 1.0.1

export DOCKER_IMAGE_NAME_TO_TEST \
  ASCIIDOCTOR_VERSION \
  ASCIIDOCTOR_CONFLUENCE_VERSION \
  ASCIIDOCTOR_PDF_VERSION \
  ASCIIDOCTOR_DIAGRAM_VERSION \
  ASCIIDOCTOR_EPUB3_VERSION \
  ASCIIDOCTOR_MATHEMATICAL_VERSION \
  ASCIIDOCTOR_REVEALJS_VERSION \
  KRAMDOWN_ASCIIDOC_VERSION

all: build test deploy

build:
	docker build \
		--tag="$(DOCKER_IMAGE_NAME_TO_TEST)" \
		--file=Dockerfile \
		$(CURDIR)/

test:
	bats $(CURDIR)/tests/*.bats

deploy:
ifdef DOCKER_HUB_TRIGGER_URL

	curl --verbose --header "Content-Type: application/json" \
		--data '{"source_type": "$(shell [ -n "${TRAVIS_TAG}" ] && echo Tag || echo Branch)", "source_name": "$(CURRENT_GIT_REF)"}' \
		-X POST $(DOCKER_HUB_TRIGGER_URL)
else
	@echo 'Unable to deploy: Please define $$DOCKER_HUB_TRIGGER_URL'
endif

.PHONY: all build test deploy
