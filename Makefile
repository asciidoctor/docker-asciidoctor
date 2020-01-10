
DOCKER_IMAGE_NAME ?= docker-asciidoctor
DOCKERHUB_USERNAME ?= asciidoctor
DOCKER_IMAGE_TEST_TAG ?= $(shell git rev-parse --short HEAD)
DOCKER_IMAGE_NAME_TO_TEST ?= $(DOCKERHUB_USERNAME)/$(DOCKER_IMAGE_NAME):$(DOCKER_IMAGE_TEST_TAG)
ASCIIDOCTOR_VERSION ?= 2.0.10
ASCIIDOCTOR_CONFLUENCE_VERSION ?= 0.0.2
ASCIIDOCTOR_PDF_VERSION ?= 1.5.0.rc.2
ASCIIDOCTOR_DIAGRAM_VERSION ?= 1.5.19
ASCIIDOCTOR_EPUB3_VERSION ?= 1.5.0.alpha.9
ASCIIDOCTOR_MATHEMATICAL_VERSION ?= 0.3.1
ASCIIDOCTOR_REVEALJS_VERSION ?= 2.0.0
CURRENT_GIT_BRANCH ?= $(shell git rev-parse --abbrev-ref HEAD)

export DOCKER_IMAGE_NAME_TO_TEST \
  ASCIIDOCTOR_VERSION \
  ASCIIDOCTOR_CONFLUENCE_VERSION \
  ASCIIDOCTOR_PDF_VERSION \
  ASCIIDOCTOR_DIAGRAM_VERSION \
  ASCIIDOCTOR_EPUB3_VERSION \
  ASCIIDOCTOR_MATHEMATICAL_VERSION \
  ASCIIDOCTOR_REVEALJS_VERSION

all: build test deploy

build:
	docker build \
		-t $(DOCKER_IMAGE_NAME_TO_TEST) \
		-f Dockerfile \
		$(CURDIR)/

test:
	bats $(CURDIR)/tests/*.bats

deploy:
ifdef DOCKER_HUB_TRIGGER_URL
	curl -H "Content-Type: application/json" \
		--data '{"source_type": "Branch", "source_name": "$(CURRENT_GIT_BRANCH)"}' \
		-X POST $(DOCKER_HUB_TRIGGER_URL)
else
	@echo 'Unable to deploy: Please define $$DOCKER_HUB_TRIGGER_URL'
endif

clean:
	rm -rf "$(CURDIR)/cache"

cache:
	mkdir -p "$(CURDIR)/cache"

cache/pandoc-2.2-linux.tar.gz: cache
	curl -sSL -o "$(CURDIR)/cache/pandoc-2.2-linux.tar.gz" \
	 	https://github.com/jgm/pandoc/releases/download/2.2/pandoc-2.2-linux.tar.gz

cache/pandoc-2.2/bin/pandoc: cache/pandoc-2.2-linux.tar.gz
	tar xzf "$(CURDIR)/cache/pandoc-2.2-linux.tar.gz" -C "$(CURDIR)/cache"

README.md: build cache/pandoc-2.2/bin/pandoc
	docker run --rm -t -v $(CURDIR):/documents --entrypoint bash $(DOCKER_IMAGE_NAME_TO_TEST) \
		-c "asciidoctor -b docbook -a leveloffset=+1 -o - README.adoc | /documents/cache/pandoc-2.2/bin/pandoc  --atx-headers --wrap=preserve -t gfm -f docbook - > README.md"
	git add README.md && git commit -s -m "Updating README.md using 'make README.md command'" \
		&& git push origin $(shell git rev-parse --abbrev-ref HEAD) || echo 'No changes to README.md'

.PHONY: all build test deploy clean README.md
