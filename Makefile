
DOCKER_IMAGE_NAME ?= docker-asciidoctor
DOCKERHUB_USERNAME ?= asciidoctor
DOCKER_IMAGE_TEST_TAG ?= $(shell git rev-parse --short HEAD)
DOCKER_IMAGE_NAME_TO_TEST ?= $(DOCKERHUB_USERNAME)/$(DOCKER_IMAGE_NAME):$(DOCKER_IMAGE_TEST_TAG)
ASCIIDOCTOR_VERSION ?= 1.5.7
ASCIIDOCTOR_PDF_VERSION ?= 1.5.0.alpha.16
CURRENT_GIT_BRANCH ?= $(shell git rev-parse --abbrev-ref HEAD)

export DOCKER_IMAGE_NAME_TO_TEST ASCIIDOCTOR_VERSION ASCIIDOCTOR_PDF_VERSION

all: build test deploy

build:
	docker build \
		-t $(DOCKER_IMAGE_NAME_TO_TEST) \
		-f Dockerfile \
		$(CURDIR)/

test:
	bats $(CURDIR)/tests/*.bats

deploy:
	curl -H "Content-Type: application/json" \
		--data '{"source_type": "Branch", "source_name": "$(CURRENT_GIT_BRANCH)"}' \
		-X POST https://registry.hub.docker.com/u/$(DOCKERHUB_USERNAME)/$(DOCKER_IMAGE_NAME)/trigger/$(DOCKER_HUB_TOKEN)/

.PHONY: all build test deploy
