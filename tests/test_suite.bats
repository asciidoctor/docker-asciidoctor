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

@test "Timezone data is present in the image" {
  docker run -t --rm "${DOCKER_IMAGE_NAME_TO_TEST}" test -f /usr/share/zoneinfo/posixrules
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

@test "python3 is installed, in the path, and executable" {
  docker run -t --rm "${DOCKER_IMAGE_NAME_TO_TEST}" which python3
  docker run -t --rm "${DOCKER_IMAGE_NAME_TO_TEST}" python3 --version
}

@test "dot (from Graphviz) is installed and in the path" {
  docker run -t --rm "${DOCKER_IMAGE_NAME_TO_TEST}" which dot
}

@test "asciidoctor-confluence is installed and in the path" {
  docker run -t --rm "${DOCKER_IMAGE_NAME_TO_TEST}" which asciidoctor-confluence
}

@test "kramdoc is installed and in the path" {
  docker run -t --rm "${DOCKER_IMAGE_NAME_TO_TEST}" which kramdoc
  docker run -t --rm "${DOCKER_IMAGE_NAME_TO_TEST}" kramdoc --version
}

@test "git command line tool is installed and in the path" {
  docker run -t --rm "${DOCKER_IMAGE_NAME_TO_TEST}" which git
  docker run -t --rm "${DOCKER_IMAGE_NAME_TO_TEST}" git --version
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

@test "DejaVu Fonts are installed to get corretly rendered PlantUML-Graphs" {
  docker run -t --rm "${DOCKER_IMAGE_NAME_TO_TEST}" fc-list "DejaVu Sans"
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

@test "We can generate HTML documents with different syntax-colored codes" {
  docker run -t --rm \
  -v "${BATS_TEST_DIRNAME}":/documents/ \
  "${DOCKER_IMAGE_NAME_TO_TEST}" \
    asciidoctor --trace -D /documents/tmp -r asciidoctor-mathematical \
    /documents/fixtures/samples-syntax-highlight/*.adoc
}

@test "We can generate PDF documents with different syntax-colored codes" {
  docker run -t --rm \
    -v "${BATS_TEST_DIRNAME}":/documents/ \
    "${DOCKER_IMAGE_NAME_TO_TEST}" \
      asciidoctor-pdf -D /documents/tmp \
      /documents/fixtures/samples-syntax-highlight/*.adoc
}

@test "We can convert a Markdown file to an AsciiDoc file" {
  docker run -t --rm \
    -v "${BATS_TEST_DIRNAME}":/documents/ \
    "${DOCKER_IMAGE_NAME_TO_TEST}" \
      kramdoc /documents/fixtures/sample-markdown.md \
      -o /documents/tmp/sample-markdown.adoc
}

@test "We can produce a website with citations from bibtex" {
  docker run -t --rm \
    -v "${BATS_TEST_DIRNAME}":/documents/ \
    "${DOCKER_IMAGE_NAME_TO_TEST}" \
      asciidoctor -r asciidoctor-bibtex \
      -o /documents/tmp/sample-with-bib.html \
      /documents/fixtures/sample-with-bib.adoc

  grep 'Mane' ${TMP_GENERATION_DIR}/sample-with-bib.html
}
