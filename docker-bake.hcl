variable "CACHE_REGISTRY_PREFIX" {
  default = "ghcr.io/asciidoctor"
}

group "all" {
  targets = [
    "asciidoctor-minimal",
    "build-haskell",
    "asciidoctor"
  ]
}

target "asciidoctor-minimal" {
  dockerfile = "Dockerfile"
  context = "."
  target = "main-minimal"
  tags = [
    "asciidoctor-minimal", // Required for test harness
  ]
  cache-from = [
    "${CACHE_REGISTRY_PREFIX}/asciidoctor-minimal:cache",
  ]
  cache-to = [
    "${CACHE_REGISTRY_PREFIX}/asciidoctor-minimal:cache",
  ]
}

// This image is only used for intermediate steps
target "build-haskell" {
  dockerfile = "Dockerfile"
  context = "."
  target = "build-haskell"
  cache-from = [
    "${CACHE_REGISTRY_PREFIX}/build-haskell:cache",
  ]
  cache-to = [
    "${CACHE_REGISTRY_PREFIX}/build-haskell:cache",
  ]
}

target "asciidoctor" {
  dockerfile = "Dockerfile"
  context = "."
  target = "main"
  tags = [
    "asciidoctor", // Required for test harness
  ]
  cache-from = [
    "${CACHE_REGISTRY_PREFIX}/asciidoctor:cache",
  ]
  cache-to = [
    "${CACHE_REGISTRY_PREFIX}/asciidoctor:cache",
  ]
}
