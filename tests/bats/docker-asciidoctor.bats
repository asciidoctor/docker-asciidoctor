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
      docker-asciidoctor ${*}
}

## Those are the tests
@test "A simple asciidoc source can be converted to HTML" {
  docker_run_asciidoc_test asciidoctor -D /out ./simple.adoc

  grep html "${TMP_RENDERING_DIR}/simple.html"
}

@test "A simple asciidoc source can be converted to PDF" {
  docker_run_asciidoc_test asciidoctor-pdf -D /out ./simple.adoc

  cat "${TMP_RENDERING_DIR}/simple.pdf" | strings | grep %PDF
}

@test "A simple (but adapted) asciidoc source can be converted to ePub" {
  docker_run_asciidoc_test asciidoctor-epub3 -D /out ./simple-epub.adoc

  cat "${TMP_RENDERING_DIR}/simple-epub.epub" | strings \
    | grep 'mimetypeapplication/epub'

}

@test "A simple asciidoc with different diagrams can be converted to HTML" {
  docker_run_asciidoc_test asciidoctor -D /out -r asciidoctor-diagram \
    ./simple-diag.adoc

  grep html "${TMP_RENDERING_DIR}/simple-diag.html"
}

@test "A simple asciidoc source can be converted to PDF" {
  docker_run_asciidoc_test asciidoctor-pdf -D /out -r asciidoctor-diagram \
    ./simple-diag.adoc

  cat "${TMP_RENDERING_DIR}/simple-diag.pdf" | strings | grep %PDF
}

@test "A simple (but adapted) asciidoc source can be converted to ePub" {
  docker_run_asciidoc_test asciidoctor-epub3 -D /out -r asciidoctor-diagram \
    ./simple-diag-epub.adoc

  cat "${TMP_RENDERING_DIR}/simple-diag-epub.epub" | strings \
    | grep 'mimetypeapplication/epub'

}

@test "A simple adoc2slide using dzslide backend" {
  # Workaround #1, but dzslides from mojavelinux HAS to be aside doc
  # Workaround #2 : remove the non US-ASCII README :( (THanks Cédric :))
  # So a script has been made. Tip will be to patch the backend README

  docker_run_asciidoc_test bash ./workaround-slides.sh

  grep '<html' "${TMP_RENDERING_DIR}/slides.html"
  grep 'dzslides' "${TMP_RENDERING_DIR}/slides.html"

}

@test "Reusing the simple Adoc with docbook and fopub" {
  docker_run_asciidoc_test asciidoctor -D /out -b docbook ./simple.adoc
  grep '<?xml' "${TMP_RENDERING_DIR}/simple.xml"

  docker_run_asciidoc_test fopub /out/simple.xml
  cat "${TMP_RENDERING_DIR}/simple.pdf" | strings | grep %PDF

}
