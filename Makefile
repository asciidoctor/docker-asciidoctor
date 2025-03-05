
export DOCKER_BUILDKIT=1
GIT_TAG = $(shell git describe --exact-match --tags HEAD 2>/dev/null)
ifeq ($(strip $(GIT_TAG)),)
GIT_REF = $(shell git rev-parse --abbrev-ref HEAD 2>/dev/null)
else
GIT_REF = $(GIT_TAG)
endif
ARCH = $(shell uname -m)
LOCAL_TARGET = $(shell if [ $(ARCH) = "aarch64" ] || [ $(ARCH) = "arm64" ]; then echo "linux/arm64"; else echo "linux/amd64"; fi)
BUILDER = $(shell if $$(docker buildx use asciidoctor 2> /dev/null) ; then echo "true"; else echo "false"; fi)

PANDOC_VERSION ?= 3.6.3

all: build test README
all-load: build-load test README

build-load: builder-init asciidoctor-minimal.build-load erd-builder.build-load asciidoctor.build-load
build: build-load asciidoctor-minimal.build erd-builder.build asciidoctor.build

%.build-load:
	docker buildx bake $(*) --set *.platform=$(LOCAL_TARGET) --load --builder=asciidoctor --print
	docker buildx bake $(*) --set *.platform=$(LOCAL_TARGET) --load --builder=asciidoctor

%.build:
	docker buildx bake $(*) --builder=asciidoctor --print
	docker buildx bake $(*) --builder=asciidoctor

test: asciidoctor.test

%.test:
	bats $(CURDIR)/tests/$(*).bats

deploy: asciidoctor.deploy

%.deploy:
	docker buildx bake $(*) --push --builder=asciidoctor --print
	docker buildx bake $(*) --push --builder=asciidoctor

builder-init:
	if [ $(BUILDER) = false ]; then docker buildx create --name asciidoctor --driver docker-container --use && docker buildx inspect --bootstrap; fi

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
# This recipe creates README.md from README.adoc
README: asciidoctor.build cache/pandoc-$(PANDOC_VERSION)/bin/pandoc
	docker run --rm -t -v $(CURDIR):/documents --entrypoint bash asciidoctor \
		-c "asciidoctor -b docbook -a leveloffset=+1 -o - README.adoc | /documents/cache/pandoc-$(PANDOC_VERSION)/bin/pandoc --markdown-headings=atx --wrap=preserve -t gfm -f docbook - > README.md"

deploy-README: README
	git add README.adoc README.md && git commit -s -m "Updating README files using 'make README command'" \
		&& git push origin $(shell git rev-parse --abbrev-ref HEAD) || echo 'No changes to README files'

.PHONY: all build build-load builder-init test deploy clean README deploy-README docker-cache
