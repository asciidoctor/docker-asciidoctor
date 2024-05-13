#!/usr/bin/env bats

TMP_GENERATION_DIR="${BATS_TEST_DIRNAME}/tmp"
ALPINE_VERSION=3.19.1
ASCIIDOCTOR_VERSION=2.0.22
ASCIIDOCTOR_CONFLUENCE_VERSION=0.0.2
ASCIIDOCTOR_PDF_VERSION=2.3.15
ASCIIDOCTOR_DIAGRAM_VERSION=2.3.0
ASCIIDOCTOR_EPUB3_VERSION=2.1.3
ASCIIDOCTOR_FB2_VERSION=0.7.0
ASCIIDOCTOR_MATHEMATICAL_VERSION=0.3.5
ASCIIDOCTOR_REVEALJS_VERSION=5.1.0
KRAMDOWN_ASCIIDOC_VERSION=2.1.0
ASCIIDOCTOR_BIBTEX_VERSION=0.9.0
ASCIIDOCTOR_KROKI_VERSION=0.10.0
DOCKER_IMAGE_NAME_TO_TEST="${IMAGE_NAME:-asciidoctor}"

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

@test "The Docker image to test is available" {
  docker inspect "${DOCKER_IMAGE_NAME_TO_TEST}"
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
  docker run -t --rm "${DOCKER_IMAGE_NAME_TO_TEST}" asciidoctor-revealjs -v \
    | grep "${ASCIIDOCTOR_REVEALJS_VERSION}"
}

@test "make is installed and in the path" {
  docker run -t --rm "${DOCKER_IMAGE_NAME_TO_TEST}" which make
}

@test "asciidoctor-epub3 is installed and in the path" {
  docker run -t --rm "${DOCKER_IMAGE_NAME_TO_TEST}" which asciidoctor-epub3
}

@test "asciidoctor-fb2 is installed and in version ${ASCIIDOCTOR_FB2_VERSION}" {
  docker run -t --rm "${DOCKER_IMAGE_NAME_TO_TEST}" asciidoctor-fb2 -v \
    | grep "Asciidoctor FB2" | grep "${ASCIIDOCTOR_VERSION}" \
    | grep "${ASCIIDOCTOR_FB2_VERSION}"
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

@test "a2s is installed and in the path" {
  docker run -t --rm "${DOCKER_IMAGE_NAME_TO_TEST}" which a2s
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

@test "We can generate an FB2 document from basic example without errors/warnings" {

  docker run -t --rm \
    -v "${BATS_TEST_DIRNAME}":/documents/ \
    "${DOCKER_IMAGE_NAME_TO_TEST}" \
      asciidoctor-fb2 -D /documents/tmp -r asciidoctor-mathematical \
      --failure-level WARN \
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

@test "asciidoctor-kroki is installed as a gem with the version ${ASCIIDOCTOR_KROKI_VERSION}" {
  docker run -t --rm "${DOCKER_IMAGE_NAME_TO_TEST}" gem list \
    | grep "asciidoctor-kroki" | grep "${ASCIIDOCTOR_KROKI_VERSION}"
}

@test "We can generate an HTML document with a diagram with asciidoctor-kroki as backend" {
  run docker run -t --rm \
    -v "${BATS_TEST_DIRNAME}":/documents/ \
    "${DOCKER_IMAGE_NAME_TO_TEST}" \
      asciidoctor -D /documents/tmp -r asciidoctor-kroki \
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

@test "Noto CJK Fonts are installed to render correctly the PlantUML diagram from asciidoctor-diagram" {
  docker run -t --rm "${DOCKER_IMAGE_NAME_TO_TEST}" apk info font-noto-cjk
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
