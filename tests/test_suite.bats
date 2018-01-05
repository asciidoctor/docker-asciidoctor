#!/usr/bin/env bats

DOCKER_IMAGE_NAME="docker-asciidoctor:test"
TMP_GENERATION_DIR="${BATS_TEST_DIRNAME}/tmp"
ASCIIDOCTOR_VERSION="1.5.6.1"
ASCIIDOCTOR_PDF_VERSION="1.5.0.alpha.16"

clean_generated_files() {
  docker run -t --rm -v "${BATS_TEST_DIRNAME}:${BATS_TEST_DIRNAME}" alpine \
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

@test "asciidoctor-pdf is installed and in version ${ASCIIDOCTOR_PDF_VERSION}" {
  docker run -t --rm "${DOCKER_IMAGE_NAME}" asciidoctor-pdf -v \
    | grep "Asciidoctor PDF" | grep "${ASCIIDOCTOR_VERSION}" \
    | grep "${ASCIIDOCTOR_PDF_VERSION}"
}

@test "asciidoctor-revealjs is callable without error" {
  docker run -t --rm "${DOCKER_IMAGE_NAME}" asciidoctor-revealjs -v
}

@test "make is installed and in the path" {
  docker run -t --rm "${DOCKER_IMAGE_NAME}" which make
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

@test "Bakoma Fonts are installed to render correctly the square root from asciidoctor-mathematical" {
  docker run -t --rm "${DOCKER_IMAGE_NAME}" apk info font-bakoma-ttf
}

@test "We can generate an HTML document with asciidoctor-mathematical as backend" {
  run docker run -t --rm \
    -v "${BATS_TEST_DIRNAME}":/documents/ \
    "${DOCKER_IMAGE_NAME}" \
      asciidoctor -D /documents/tmp -r asciidoctor-mathematical \
      /documents/fixtures/sample-with-latex-math.adoc

  # Even when in ERROR with the module, asciidoctor return 0 because a document
  # has been generated
  [ "${status}" -eq 0 ]

  echo "-- Output of command:"
  echo "${output}"
  echo "--"

  [ "$(echo ${output} | grep -c -i error)" -eq 0 ]
}

@test "We can generate a PDF document with asciidoctor-mathematical as backend" {
  run docker run -t --rm \
    -v "${BATS_TEST_DIRNAME}":/documents/ \
    "${DOCKER_IMAGE_NAME}" \
      asciidoctor-pdf -D /documents/tmp -r asciidoctor-mathematical \
      /documents/fixtures/sample-with-latex-math.adoc

  # Even when in ERROR with the module, asciidoctor return 0 because a document
  # has been generated
  [ "${status}" -eq 0 ]

  echo "-- Output of command:"
  echo "${output}"
  echo "--"

  [ "$(echo ${output} | grep -c -i error)" -eq 0 ]
}
