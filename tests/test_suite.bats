#!/usr/bin/env bats

DOCKER_IMAGE_NAME="docker-asciidoctor:test"
TMP_GENERATION_DIR="${BATS_TEST_DIRNAME}/tmp"
ASCIIDOCTOR_VERSION="1.5.5"

clean_generated_files() {
  rm -rf "${TMP_GENERATION_DIR}"
}

setup() {
  clean_generated_files
  mkdir -p "${TMP_GENERATION_DIR}"
}

teardown() {
  clean_generated_files
}

@test "We can build successfully the standard Docker image" {
  docker build -t "${DOCKER_IMAGE_NAME}" "${BATS_TEST_DIRNAME}/../"
}

@test "asciidoctor is installed and in version ${ASCIIDOCTOR_VERSION}" {
  docker run -t --rm "${DOCKER_IMAGE_NAME}" asciidoctor -v \
    | grep "Asciidoctor" | grep "${ASCIIDOCTOR_VERSION}"
}

@test "asciidoctor-pdf is installed and in the path" {
  docker run -t --rm "${DOCKER_IMAGE_NAME}" which asciidoctor-pdf
}

@test "asciidoctor-epub3 is installed and in the path" {
  docker run -t --rm "${DOCKER_IMAGE_NAME}" which asciidoctor-epub3
}

@test "fopub is installed and in the path" {
  docker run -t --rm "${DOCKER_IMAGE_NAME}" which fopub
}

@test "fopub can be run on an empty xml" {
  docker run -t --rm "${DOCKER_IMAGE_NAME}" bash -c "touch /tmp/empty.xml \
    && fopub /tmp/empty.xml \
    && rm /tmp/empty.xml"
}

@test "asciidoctor-confluence is installed and in the path" {
  docker run -t --rm "${DOCKER_IMAGE_NAME}" which asciidoctor-confluence
}

@test "We can generate a HTML document from basic example" {
  docker run -t --rm \
    -v "${BATS_TEST_DIRNAME}":/documents/ \
    "${DOCKER_IMAGE_NAME}" \
      asciidoctor -D /documents/tmp /documents/fixtures/basic-example.adoc
  grep '<html' ${TMP_GENERATION_DIR}/*html
}

@test "We can generate a PDF document from basic example" {
  docker run -t --rm \
    -v "${BATS_TEST_DIRNAME}":/documents/ \
    "${DOCKER_IMAGE_NAME}" \
      asciidoctor-pdf -D /documents/tmp /documents/fixtures/basic-example.adoc
}
