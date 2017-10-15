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

@test "curl is installed and in the path" {
  docker run -t --rm "${DOCKER_IMAGE_NAME}" which curl
}

@test "bash is installed and in the path" {
  docker run -t --rm "${DOCKER_IMAGE_NAME}" which bash
}

@test "java is installed, in the path, and executable" {
  docker run -t --rm "${DOCKER_IMAGE_NAME}" which java
  docker run -t --rm "${DOCKER_IMAGE_NAME}" java -version
}

@test "dot (from Graphviz) is installed and in the path" {
  docker run -t --rm "${DOCKER_IMAGE_NAME}" which dot
}

@test "asciidoctor-confluence is installed and in the path" {
  docker run -t --rm "${DOCKER_IMAGE_NAME}" which asciidoctor-confluence
}

@test "We can generate an HTML document from basic example" {
  docker run -t --rm \
    -v "${BATS_TEST_DIRNAME}":/documents/ \
    "${DOCKER_IMAGE_NAME}" \
      asciidoctor -D /documents/tmp -r asciidoctor-mathematical \
      /documents/fixtures/basic-example.adoc
  grep '<html' ${TMP_GENERATION_DIR}/*html
}

@test "We can generate a PDF document from basic example" {
  docker run -t --rm \
    -v "${BATS_TEST_DIRNAME}":/documents/ \
    "${DOCKER_IMAGE_NAME}" \
      asciidoctor-pdf -D /documents/tmp -r asciidoctor-mathematical \
      /documents/fixtures/basic-example.adoc
}

@test "We can generate an HTML document with a diagram with asciidoctor-diagram as backend" {
  run docker run -t --rm \
    -v "${BATS_TEST_DIRNAME}":/documents/ \
    "${DOCKER_IMAGE_NAME}" \
      asciidoctor -D /documents/tmp -r asciidoctor-diagram \
      /documents/fixtures/sample-with-diagram.adoc

  # Even when in ERROR with the module, asciidoctor return 0 because a document
  # has been generated
  [ "${status}" -eq 0 ]

  echo "-- Output of command:"
  echo "${output}"
  echo "--"

  [ "$(echo ${output} | grep -c -i error)" -eq 0 ]
}
