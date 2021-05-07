
DOCKER_IMAGE_NAME ?= docker-asciidoctor
DOCKERHUB_USERNAME ?= asciidoctor
export DOCKER_BUILDKIT=1
GIT_TAG = $(shell git describe --exact-match --tags HEAD 2>/dev/null)
ifeq ($(strip $(GIT_TAG)),)
GIT_REF = $(shell git rev-parse --abbrev-ref HEAD 2>/dev/null)
else
GIT_REF = $(GIT_TAG)
endif
DOCKER_IMAGE_TAG ?= $(shell echo $(GIT_REF) | sed 's/\//-/' )
DOCKER_IMAGE_NAME_TO_TEST ?= $(DOCKERHUB_USERNAME)/$(DOCKER_IMAGE_NAME):$(DOCKER_IMAGE_TAG)
export DOCKER_IMAGE_NAME_TO_TEST

TESTS_ENV_FILE ?= $(CURDIR)/tests/env_vars.yml
export TESTS_ENV_FILE

PANDOC_VERSION ?= 2.10.1

all: build test README

build:
	docker build \
		--target main-minimal \
		--tag="$(DOCKER_IMAGE_NAME_TO_TEST)-minimal" \
		--build-arg BUILDKIT_INLINE_CACHE=1 \
		--cache-from="$(DOCKER_IMAGE_NAME_TO_TEST)-minimal" \
		--file=Dockerfile \
		$(CURDIR)/
	docker build \
		--target build-haskell \
		--tag="$(DOCKER_IMAGE_NAME_TO_TEST)-build-haskell" \
		--build-arg BUILDKIT_INLINE_CACHE=1 \
		--cache-from="$(DOCKER_IMAGE_NAME_TO_TEST)-build-haskell" \
		--file=Dockerfile \
		$(CURDIR)/
	docker build \
		--target main \
		--tag="$(DOCKER_IMAGE_NAME_TO_TEST)" \
		--build-arg BUILDKIT_INLINE_CACHE=1 \
		--cache-from="$(DOCKER_IMAGE_NAME_TO_TEST)-minimal" \
		--cache-from="$(DOCKER_IMAGE_NAME_TO_TEST)-build-haskell" \
		--cache-from="$(DOCKER_IMAGE_NAME_TO_TEST)" \
		--file=Dockerfile \
		$(CURDIR)/

shell: build
	docker run -it -v $(CURDIR)/tests/fixtures:/documents/ $(DOCKER_IMAGE_NAME_TO_TEST)

test:
	bats $(CURDIR)/tests/*.bats

deploy:
ifdef DOCKERHUB_SOURCE_TOKEN
ifdef DOCKERHUB_TRIGGER_TOKEN
	curl --verbose --header "Content-Type: application/json" \
		--data '{"source_type": "$(shell [ -n "$(GIT_TAG)" ] && echo Tag || echo Branch)", "source_name": "$(GIT_REF)"}' \
		-X POST https://hub.docker.com/api/build/v1/source/$(DOCKERHUB_SOURCE_TOKEN)/trigger/$(DOCKERHUB_TRIGGER_TOKEN)/call/
else
	@echo 'Unable to deploy: Please define $$DOCKERHUB_TRIGGER_TOKEN'
	@exit 1
endif
else
	@echo 'Unable to deploy: Please define $$DOCKERHUB_SOURCE_TOKEN'
	@exit 1
endif

clean:
	rm -rf "$(CURDIR)/cache"

cache:
	mkdir -p "$(CURDIR)/cache"

cache/pandoc-$(PANDOC_VERSION)-linux.tar.gz: cache
	curl -sSL -o "$(CURDIR)/cache/pandoc-$(PANDOC_VERSION)-linux.tar.gz" \
	 	https://github.com/jgm/pandoc/releases/download/$(PANDOC_VERSION)/pandoc-$(PANDOC_VERSION)-linux-amd64.tar.gz

cache/pandoc-$(PANDOC_VERSION)/bin/pandoc: cache/pandoc-$(PANDOC_VERSION)-linux.tar.gz
	tar xzf "$(CURDIR)/cache/pandoc-$(PANDOC_VERSION)-linux.tar.gz" -C "$(CURDIR)/cache"

# GitHub renders asciidoctor but DockerHub requires markdown.
# This recipe creates README.md and README.adoc from README-original.adoc and env_vars.yml.
README: build cache/pandoc-$(PANDOC_VERSION)/bin/pandoc
	cat tests/env_vars.yml | sed -e 's/^[A-Z]/:&/' | sed '/^#/d' > "$(CURDIR)/cache/env_vars.adoc"
	cat "$(CURDIR)/cache/env_vars.adoc" README-original.adoc > README.adoc
	docker run --rm -t -v $(CURDIR):/documents --entrypoint bash $(DOCKER_IMAGE_NAME_TO_TEST) \
		-c "asciidoctor -b docbook -a leveloffset=+1 -o - README.adoc | /documents/cache/pandoc-$(PANDOC_VERSION)/bin/pandoc  --atx-headers --wrap=preserve -t gfm -f docbook - > README.md"

deploy-README: README
	git add README.adoc README.md && git commit -s -m "Updating README files using 'make README command'" \
		&& git push origin $(shell git rev-parse --abbrev-ref HEAD) || echo 'No changes to README files'

.PHONY: all build test shell deploy clean README deploy-README
