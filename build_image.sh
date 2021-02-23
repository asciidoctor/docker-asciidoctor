#!/usr/bin/env bash

# Problem: docker doesn't cache multi-stage builds by default,
#          so the full build time of ~10min hits me on every tinker-rebuild.
# Solution as per: https://github.com/moby/moby/issues/34715 is to
#  - force caching with --cache-from,
#  - use buildkit, and
#  - tell buildkit to build cacheable images.

export DOCKER_BUILDKIT=1

image_name="adoc-test"

docker build \
    --target build-ruby \
    --tag ${image_name}:build-ruby \
    --build-arg BUILDKIT_INLINE_CACHE=1 \
    --cache-from=${image_name}:build-ruby \
    .

docker build \
    --target build-haskell \
    --tag ${image_name}:build-haskell \
    --build-arg BUILDKIT_INLINE_CACHE=1 \
    --cache-from=${image_name}:build-haskell \
    .

docker build \
    --target main \
    --tag ${image_name} \
    --build-arg BUILDKIT_INLINE_CACHE=1 \
    --cache-from=${image_name}:build-ruby \
    --cache-from=${image_name}:build-haskell \
    --cache-from=${image_name} \
    .


