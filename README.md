# Asciidoctor Docker Container

## The environment

This Docker image provides:

-   [Asciidoctor](https://asciidoctor.org/) 2.0.15

-   [Asciidoctor Diagram](https://asciidoctor.org/docs/asciidoctor-diagram/) 2.1.2 with ERD and Graphviz integration (supports plantuml and graphiz diagrams)

-   [Asciidoctor PDF](https://asciidoctor.org/docs/asciidoctor-pdf/) 1.6.0

-   [Asciidoctor EPUB3](https://asciidoctor.org/docs/asciidoctor-epub3/) 1.5.1

-   [Asciidoctor FB2](https://github.com/asciidoctor/asciidoctor-fb2/) 0.5.1

-   [Asciidoctor Mathematical](https://github.com/asciidoctor/asciidoctor-mathematical) 0.3.5

-   [Asciidoctor reveal.js](https://docs.asciidoctor.org/reveal.js-converter/latest/) 4.1.0

-   [AsciiMath](https://rubygems.org/gems/asciimath)

-   Source highlighting using [Rouge](http://rouge.jneen.net), [CodeRay](https://rubygems.org/gems/coderay) or [Pygments](https://pygments.org/)

-   [Asciidoctor Confluence](https://github.com/asciidoctor/asciidoctor-confluence) 0.0.2

-   [Asciidoctor Bibtex](https://github.com/asciidoctor/asciidoctor-bibtex) 0.8.0

-   [Asciidoctor Kroki](https://github.com/Mogztter/asciidoctor-kroki) 0.5.0

This image uses Alpine Linux 3.13.5 as base image.

## How to use it

Just run:

    docker run -it -v <your directory>:/documents/ asciidoctor/docker-asciidoctor

Docker maps your directory with */documents* directory in the container.

After you start the container, you can use Asciidoctor commands to convert AsciiDoc files that you created in the directory mentioned above.
You can find several examples below.

-   To run Asciidoctor on a basic AsciiDoc file:

        asciidoctor sample.adoc
        asciidoctor-pdf sample.adoc
        asciidoctor-epub3 sample.adoc

-   To run AsciiDoc on an AsciiDoc file that contains diagrams:

        asciidoctor -r asciidoctor-diagram sample-with-diagram.adoc
        asciidoctor-pdf -r asciidoctor-diagram sample-with-diagram.adoc
        asciidoctor-epub3 -r asciidoctor-diagram sample-with-diagram.adoc

-   To use Asciidoctor Confluence:

        asciidoctor-confluence --host HOSTNAME --spaceKey SPACEKEY --title TITLE --username USER --password PASSWORD sample.adoc

-   To use Asciidoctor reveal.js with local downloaded reveal.js:

        asciidoctor-revealjs sample-slides.adoc
        asciidoctor-revealjs -r asciidoctor-diagram sample-slides.adoc

-   To use Asciidoctor reveal.js with online reveal.js:

        asciidoctor-revealjs -a revealjsdir=https://cdnjs.cloudflare.com/ajax/libs/reveal.js/3.9.2 sample-slides.adoc
        asciidoctor-revealjs -a revealjsdir=https://cdnjs.cloudflare.com/ajax/libs/reveal.js/3.9.2 -r asciidoctor-diagram sample-slides.adoc

-   To convert files in batch:

        docker run --rm -v $(pwd):/documents/ asciidoctor/docker-asciidoctor asciidoctor-pdf index.adoc

## How to contribute / do it yourself?

### Requirements

You need the following tools:

-   A bash compliant command line

-   [GNU make](http://man7.org/linux/man-pages/man1/make.1.html)

-   [Bats](https://github.com/sstephenson/bats) installed and in your bash PATH

-   Docker installed and in your path

### How to build and test?

-   Bats is used as a test suite runner. Since the ability to build is one way of testing, it is included.

-   You just have to run the Bats test suite, from the repository root:

        make test

#### Include test in your build pipeline or test manually

You can use Bats directly to test the image.
Optionally, you can specify a custom image name:

    # If you want to use a custom name for the image, OPTIONAL
    export DOCKER_IMAGE_NAME_TO_TEST=your-image-name
    bats tests/*.bats

#### Deploy

The goal for deploying is to make the Docker image available with the correct Docker tag in Docker Hub.

As a matter of trust and transparency for the end-users, the image is rebuilt by Docker Hub itself by triggering a build.
This only works under the hypothesis of a minimalistic variation between the Docker build in the CI, and the Docker build by Docker Hub.

Deploying the image requires setting the following environment variables: `DOCKERHUB_SOURCE_TOKEN` and `DOCKERHUB_TRIGGER_TOKEN`.
Their values come from a Docker Hub trigger URL: `https://hub.docker.com/api/build/v1/source/${DOCKERHUB_SOURCE_TOKEN}/trigger/${DOCKERHUB_TRIGGER_TOKEN}/call/`.

You might want to set these variables as secret values in your CI to avoid any leaking in the output (as `curl` output for instance).
