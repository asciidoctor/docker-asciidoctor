#!/bin/sh
rm -rf /asciidoctor-backends/slim/dzslides/README.adoc
asciidoctor -D /out -T /asciidoctor-backends/slim/dzslides ./slides.adoc
