#!/usr/bin/env bats

TMP_GENERATION_DIR="${BATS_TEST_DIRNAME}/tmp"

export TMP_GENERATION_DIR="${BATS_TEST_DIRNAME}/tmp"

[ -n "${DOCKER_IMAGE_NAME_TO_TEST}" ] || export DOCKER_IMAGE_NAME_TO_TEST=asciidoctor/docker-asciidoctor

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
  docker build -t "${DOCKER_IMAGE_NAME_TO_TEST}" "${BATS_TEST_DIRNAME}/../"
}

@test "asciidoctor is installed and in version ${ASCIIDOCTOR_VERSION}" {
  docker run -t --rm "${DOCKER_IMAGE_NAME_TO_TEST}" asciidoctor -v \
    | grep "Asciidoctor" | grep "${ASCIIDOCTOR_VERSION}"
}

@test "asciidoctor-pdf is installed and in version ${ASCIIDOCTOR_PDF_VERSION}" {
  docker run -t --rm "${DOCKER_IMAGE_NAME_TO_TEST}" asciidoctor-pdf -v \
    | grep "Asciidoctor PDF" | grep "${ASCIIDOCTOR_VERSION}" \
    | grep "${ASCIIDOCTOR_PDF_VERSION}"
}

@test "asciidoctor-revealjs is callable without error" {
  docker run -t --rm "${DOCKER_IMAGE_NAME_TO_TEST}" asciidoctor-revealjs -v
}

@test "make is installed and in the path" {
  docker run -t --rm "${DOCKER_IMAGE_NAME_TO_TEST}" which make
}

@test "asciidoctor-epub3 is installed and in the path" {
  docker run -t --rm "${DOCKER_IMAGE_NAME_TO_TEST}" which asciidoctor-epub3
}

@test "curl is installed and in the path" {
  docker run -t --rm "${DOCKER_IMAGE_NAME_TO_TEST}" which curl
}

@test "bash is installed and in the path" {
  docker run -t --rm "${DOCKER_IMAGE_NAME_TO_TEST}" which bash
}

@test "java is installed, in the path, and executable" {
  docker run -t --rm "${DOCKER_IMAGE_NAME_TO_TEST}" which java
  docker run -t --rm "${DOCKER_IMAGE_NAME_TO_TEST}" java -version
}

@test "dot (from Graphviz) is installed and in the path" {
  docker run -t --rm "${DOCKER_IMAGE_NAME_TO_TEST}" which dot
}

@test "asciidoctor-confluence is installed and in the path" {
  docker run -t --rm "${DOCKER_IMAGE_NAME_TO_TEST}" which asciidoctor-confluence
}

@test "We can generate an HTML document from basic example" {
  docker run -t --rm \
    -v "${BATS_TEST_DIRNAME}":/documents/ \
    "${DOCKER_IMAGE_NAME_TO_TEST}" \
      asciidoctor -D /documents/tmp -r asciidoctor-mathematical \
      /documents/fixtures/basic-example.adoc
  grep '<html' ${TMP_GENERATION_DIR}/*html
}

@test "We can generate a PDF document from basic example" {
  docker run -t --rm \
    -v "${BATS_TEST_DIRNAME}":/documents/ \
    "${DOCKER_IMAGE_NAME_TO_TEST}" \
      asciidoctor-pdf -D /documents/tmp -r asciidoctor-mathematical \
      /documents/fixtures/basic-example.adoc
}

@test "We can generate an HTML document with a diagram with asciidoctor-diagram as backend" {
  run docker run -t --rm \
    -v "${BATS_TEST_DIRNAME}":/documents/ \
    "${DOCKER_IMAGE_NAME_TO_TEST}" \
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
  docker run -t --rm "${DOCKER_IMAGE_NAME_TO_TEST}" apk info font-bakoma-ttf
}

@test "We can generate an HTML document with asciidoctor-mathematical as backend" {
  run docker run -t --rm \
    -v "${BATS_TEST_DIRNAME}":/documents/ \
    "${DOCKER_IMAGE_NAME_TO_TEST}" \
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

@test "We can generate an EPub document with asciidoctor-epub3" {

  run docker run -t --rm \
    -v "${BATS_TEST_DIRNAME}":/documents/ \
    "${DOCKER_IMAGE_NAME_TO_TEST}" \
      asciidoctor-epub3 /documents/fixtures/epub-sample/sample-book.adoc -D /documents/tmp

  [ "${status}" -eq 0 ]

}

@test "We can generate an HTML document with asciimath as backend" {
  run docker run -t --rm \
    -v "${BATS_TEST_DIRNAME}":/documents/ \
    "${DOCKER_IMAGE_NAME_TO_TEST}" \
      asciidoctor -D /documents/tmp -r asciimath \
      /documents/fixtures/sample-with-asciimath.adoc

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
    "${DOCKER_IMAGE_NAME_TO_TEST}" \
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

# asciimath isn't tested with the PDF backend because it doesn't support stem blocks
# without image rendering

@test "We can generate a Reveal.js Slide deck" {
  run docker run -t --rm \
    -v "${BATS_TEST_DIRNAME}":/documents/ \
    "${DOCKER_IMAGE_NAME_TO_TEST}" \
      asciidoctor-revealjs -D /documents/tmp -r asciidoctor-diagram \
      /documents/fixtures/sample-slides.adoc

  # Even when in ERROR with the module, asciidoctor return 0 because a document
  # has been generated
  [ "${status}" -eq 0 ]

  echo "-- Output of command:"
  echo "${output}"
  echo "--"

  [ "$(echo ${output} | grep -c -i error)" -eq 0 ]
}
