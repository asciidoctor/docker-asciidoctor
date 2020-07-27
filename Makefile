
DOCKER_IMAGE_NAME ?= docker-asciidoctor
DOCKERHUB_USERNAME ?= asciidoctor
CURRENT_GIT_REF ?= $(shell git rev-parse --abbrev-ref HEAD) # Default to current branch
DOCKER_IMAGE_TAG ?= $(shell echo $(CURRENT_GIT_REF) | sed 's/\//-/' )
DOCKER_IMAGE_NAME_TO_TEST ?= $(DOCKERHUB_USERNAME)/$(DOCKER_IMAGE_NAME):$(DOCKER_IMAGE_TAG)
ASCIIDOCTOR_VERSION ?= 2.0.10
ASCIIDOCTOR_CONFLUENCE_VERSION ?= 0.0.2
ASCIIDOCTOR_PDF_VERSION ?= 1.5.3
ASCIIDOCTOR_DIAGRAM_VERSION ?= 2.0.1
ASCIIDOCTOR_EPUB3_VERSION ?= 1.5.0.alpha.18
ASCIIDOCTOR_MATHEMATICAL_VERSION ?= 0.3.1
ASCIIDOCTOR_REVEALJS_VERSION ?= 4.0.1
KRAMDOWN_ASCIIDOC_VERSION ?= 1.0.1
ASCIIDOCTOR_BIBTEX_VERSION ?= 0.7.1

export DOCKER_IMAGE_NAME_TO_TEST \
  ASCIIDOCTOR_VERSION \
  ASCIIDOCTOR_CONFLUENCE_VERSION \
  ASCIIDOCTOR_PDF_VERSION \
  ASCIIDOCTOR_DIAGRAM_VERSION \
  ASCIIDOCTOR_EPUB3_VERSION \
  ASCIIDOCTOR_MATHEMATICAL_VERSION \
  ASCIIDOCTOR_REVEALJS_VERSION \
  KRAMDOWN_ASCIIDOC_VERSION \
  ASCIIDOCTOR_BIBTEX_VERSION

all: build test deploy

build:
	docker build \
		--tag="$(DOCKER_IMAGE_NAME_TO_TEST)" \
		--file=Dockerfile \
		$(CURDIR)/

shell: build
	docker run -it -v $(CURDIR)/tests/fixtures:/documents/ $(DOCKER_IMAGE_NAME_TO_TEST)

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

clean:
	rm -rf "$(CURDIR)/cache"

cache:
	mkdir -p "$(CURDIR)/cache"

cache/pandoc-2.2-linux.tar.gz: cache
	curl -sSL -o "$(CURDIR)/cache/pandoc-2.2-linux.tar.gz" \
	 	https://github.com/jgm/pandoc/releases/download/2.2/pandoc-2.2-linux.tar.gz

cache/pandoc-2.2/bin/pandoc: cache/pandoc-2.2-linux.tar.gz
	tar xzf "$(CURDIR)/cache/pandoc-2.2-linux.tar.gz" -C "$(CURDIR)/cache"

# GitHub renders asciidoctor but DockerHub requires markdown.
# This recipe creates README.md from README.adoc.
README.md: build cache/pandoc-2.2/bin/pandoc
	docker run --rm -t -v $(CURDIR):/documents --entrypoint bash $(DOCKER_IMAGE_NAME_TO_TEST) \
		-c "asciidoctor -b docbook -a leveloffset=+1 -o - README.adoc | /documents/cache/pandoc-2.2/bin/pandoc  --atx-headers --wrap=preserve -t gfm -f docbook - > README.md"
	git add README.md && git commit -s -m "Updating README.md using 'make README.md command'" \
		&& git push origin $(shell git rev-parse --abbrev-ref HEAD) || echo 'No changes to README.md'

.PHONY: all build test deploy clean README.md
