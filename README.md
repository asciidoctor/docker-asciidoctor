# Asciidoctor Docker Container

## The environment

This Docker container provides:

  - Asciidoctor 1.5.6.1

  - Aciidoctor Diagram with Graphviz integration so you can use plantuml and graphiz diagrams

  - Asciidoctor PDF (alpha)

  - Asciidoctor EPUB3 (alpha)

  - Source highlighting using CodeRay or Pygments

  - Asciidoctor backends

  - Asciidoctor-fopub

  - Asciidoctor-confluence

  - Lazybones (for Asciidoctor-revealjs)

## How to use it

Just run:

``` bash
docker run -it -v <your directory>:/documents/ asciidoctor/docker-asciidoctor
```

It will be directly mapped with */documents* of the container.

Once started, you just have to create AsciiDoc files (in the directory mentioned above) and run Asciidoctor commands like:

  - To run Asciidoctor on a basic AsciiDoc file:
    
    ``` bash
    asciidoctor sample.adoc
    asciidoctor-pdf sample.adoc
    asciidoctor-epub3 sample.adoc
    ```

  - To run AsciiDoc on an AsciiDoc file that contains diagrams:
    
    ``` bash
    asciidoctor -r asciidoctor-diagram sample-with-diagram.adoc
    asciidoctor-pdf -r asciidoctor-diagram sample-with-diagram.adoc
    asciidoctor-epub3 -r asciidoctor-diagram sample-with-diagram.adoc
    ```

  - To use Asciidoctor-backends use -T with either `/asciidoctor-backends` or `$BACKENDS` followed by the backend you want to use. For example:

<!-- end list -->

    asciidoctor -T /asciidoctor-backends/slim/dzslides myFile.adoc
    #or
    asciidoctor -T $BACKENDS/slim/dzslides myFile.adoc

  - To use fopub, you first need to generate the docbook file then use fopub:
    
    ``` bash
    asciidoctor -b docbook sample.adoc
    fopub sample.xml
    ```

  - To use asciidoctor-confluence
    
    ``` bash
    asciidoctor-confluence --host HOSTNAME --spaceKey SPACEKEY --title TITLE --username USER --password PASSWORD sample.adoc
    ```

  - Batch mode. You can use it in a "batch" mode
    
    ``` bash
    docker run --rm -v $(pwd):/documents/ asciidoctor/docker-asciidoctor asciidoctor-pdf index.adoc
    ```

## How to contribute / do it yourself ?

### Requirements

You need the following tools:

  - A bash compliant command line

  - [bats](https://github.com/sstephenson/bats) installed and in your bash PATH

  - Docker installed and in your path

### How to build and test ?

  - "bats" is used as a test suite runner. Since the ability to build is one
    way of testing, it is included.

  - You just have to run the bats test suite, from the repository root:

<!-- end list -->

``` bash
bats ./tests/test_suite.bats
```
