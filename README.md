# Asciidoctor Docker Container

## The environment

This Docker image provides:

  - Asciidoctor 2.0.10

  - Asciidoctor Diagram 1.5.19 with Graphviz integration (supports plantuml and graphiz diagrams)

  - Asciidoctor PDF 1.5.0.rc.3

  - Asciidoctor EPUB3 1.5.0.alpha.12

  - Asciidoctor Mathematical

  - Asciidoctor reveal.js 3.1.0

  - AsciiMath

  - Source highlighting using Rouge or CodeRay (Pygments not supported in the default Docker image as only Python 3 is available)

  - Asciidoctor Confluence

This image uses Alpine Linux 3.11 as base image.

## How to use it

Just run:

``` bash
docker run -it -v <your directory>:/documents/ asciidoctor/docker-asciidoctor
```

It will be directly mapped with */documents* of the container.

Once started, you can use Asciidoctor commands to convert AsciiDoc files you created in the directory mentioned above. You can find several examples below.

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

  - To use Asciidoctor Confluence:
    
    ``` bash
    asciidoctor-confluence --host HOSTNAME --spaceKey SPACEKEY --title TITLE --username USER --password PASSWORD sample.adoc
    ```

  - To use Asciidoctor reveal.js with local downloaded reveal.js:

<!-- end list -->

``` bash
asciidoctor-revealjs sample-slides.adoc
asciidoctor-revealjs -r asciidoctor-diagram sample-slides.adoc
```

  - To use Asciidoctor reveal.js with online reveal.js:

<!-- end list -->

``` bash
asciidoctor-revealjs -a revealjsdir=https://cdnjs.cloudflare.com/ajax/libs/reveal.js/3.8.0 sample-slides.adoc
asciidoctor-revealjs -a revealjsdir=https://cdnjs.cloudflare.com/ajax/libs/reveal.js/3.8.0 -r asciidoctor-diagram sample-slides.adoc
```

  - Batch mode. You can use it in a "batch" mode
    
    ``` bash
    docker run --rm -v $(pwd):/documents/ asciidoctor/docker-asciidoctor asciidoctor-pdf index.adoc
    ```

## How to contribute / do it yourself ?

### Requirements

You need the following tools:

  - A bash compliant command line

  - [GNU make](http://man7.org/linux/man-pages/man1/make.1.html)

  - [bats](https://github.com/sstephenson/bats) installed and in your bash PATH

  - Docker installed and in your path

### How to build and test ?

  - "bats" is used as a test suite runner. Since the ability to build is one way of testing, it is included.

  - You just have to run the bats test suite, from the repository root:
    
    ``` bash
    make test
    ```

#### Include test in your build pipeline or test manually

You can use bats directly to test the image, optional you can use a custome image name:

``` bash
# If you want to use a custom name for the image, OPTIONAL
export DOCKER_IMAGE_NAME_TO_TEST=your-image-name
bats tests/*.bats
```
