#!/usr/bin/env bats

BASE_DIR="${BATS_TEST_DIRNAME}/../.."
FIXTURE_DIR="${BASE_DIR}/tests/fixtures"
TMP_RENDERING_DIR="${BASE_DIR}/.tmp-render"

## Those function are executed before/after each test case
setup() {
  mkdir -p "${TMP_RENDERING_DIR}" >&2
}
teardown() {
  rm -rf "${TMP_RENDERING_DIR}" >&2
}

## Utility function to launch a container with premounting fixtures for tests
docker_run_asciidoc_test() {
  docker run -it -v "${FIXTURE_DIR}":/documents -v "${TMP_RENDERING_DIR}":/out \
      asciidoctor/docker-asciidoctor ${*}
}

## Those are the tests
@test "A simple asciidoc source can be converted to HTML" {
  docker_run_asciidoc_test asciidoctor -D /out /documents/simple.adoc

  grep html "${TMP_RENDERING_DIR}/simple.html"
}

@test "A simple asciidoc source can be converted to PDF" {
  docker_run_asciidoc_test asciidoctor-pdf -D /out /documents/simple.adoc

  cat "${TMP_RENDERING_DIR}/simple.pdf" | strings | grep %PDF
}

@test "A simple (but adapted) asciidoc source can be converted to ePub" {
  docker_run_asciidoc_test asciidoctor-epub3 -D /out /documents/simple-epub.adoc

  cat "${TMP_RENDERING_DIR}/simple-epub.epub" | strings | grep 'mimetypeapplication/epub'

}
