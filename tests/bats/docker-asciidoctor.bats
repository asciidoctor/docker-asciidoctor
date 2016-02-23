#!/usr/bin/env bats

BASE_DIR="${BATS_TEST_DIRNAME}/../.."
FIXTURE_DIR="${BASE_DIR}/tests/fixtures"

@test "A simple asciidoc source can be converted to HTML" {
  local RENDERED_FILE="${FIXTURE_DIR}/simple.html"
  # Cleaning
  rm -f "${RENDERED_FILE}"

  # Running test case
  docker run -it -v "${FIXTURE_DIR}":/docs asciidoctor/docker-asciidoctor \
      asciidoctor /docs/simple.adoc

  # Verifying final state
  [ -f "${RENDERED_FILE}" ]
  grep html "${RENDERED_FILE}"
}

@test "A simple asciidoc source can be converted to PDF" {
  local RENDERED_FILE="${FIXTURE_DIR}/simple.pdf"
  # Cleaning
  rm -f "${RENDERED_FILE}"

  # Running test case
  docker run -it -v "${FIXTURE_DIR}":/docs asciidoctor/docker-asciidoctor \
      asciidoctor-pdf /docs/simple.adoc

  # Verifying final state
  [ -f "${RENDERED_FILE}" ]
  cat "${RENDERED_FILE}" | strings | grep %PDF
}

@test "A simple (but adapted) asciidoc source can be converted to ePub" {
  skip "TODO"
  rm -f "${FIXTURE_DIR}/simple.html"
  docker run -it -v $(pwd):/docs asciidoctor/docker-asciidoctor \
    asciidoctor /docs/tests/fixtures/simple.adoc
  [ -f "${FIXTURE_DIR}/simple.html" ]
}
