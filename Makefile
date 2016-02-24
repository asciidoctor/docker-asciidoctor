.PHONY: build test all

DOCKER_IMAGE_NAME=asciidoctor/docker-asciidoctor:latest

all: build test

build:
	docker build \
		--tag $(DOCKER_IMAGE_NAME) \
		./

test:
	DOCKER_IMAGE_NAME=$(DOCKER_IMAGE_NAME) bats $(CURDIR)/tests/bats/*.bats
