# Asciidoctor Docker Container

## The environment

This Docker image provides:

-   [Asciidoctor](https://asciidoctor.org/) 2.0.21

-   [Asciidoctor Diagram](https://asciidoctor.org/docs/asciidoctor-diagram/) 2.3.0 with ERD and Graphviz integration (supports plantuml and graphiz diagrams)

-   [Asciidoctor PDF](https://asciidoctor.org/docs/asciidoctor-pdf/) 2.3.13

-   [Asciidoctor EPUB3](https://asciidoctor.org/docs/asciidoctor-epub3/) 2.1.0

-   [Asciidoctor FB2](https://github.com/asciidoctor/asciidoctor-fb2/) 0.7.0

-   [Asciidoctor Mathematical](https://github.com/asciidoctor/asciidoctor-mathematical) 0.3.5

-   [Asciidoctor reveal.js](https://docs.asciidoctor.org/reveal.js-converter/latest/) 5.1.0

-   [AsciiMath](https://rubygems.org/gems/asciimath)

-   Source highlighting using [Rouge](http://rouge.jneen.net), [CodeRay](https://rubygems.org/gems/coderay) or [Pygments](https://pygments.org/)

-   [Asciidoctor Confluence](https://github.com/asciidoctor/asciidoctor-confluence) 0.0.2

-   [Asciidoctor Bibtex](https://github.com/asciidoctor/asciidoctor-bibtex) 0.9.0

-   [Asciidoctor Kroki](https://github.com/Mogztter/asciidoctor-kroki) 0.9.1

-   [Asciidoctor Reducer](https://github.com/asciidoctor/asciidoctor-reducer) 1.0.2

This image uses Alpine Linux 3.19.1 as base image.

<div class="note">

Docker Engine [20.10](https://docs.docker.com/engine/release-notes/#20100) or later is required (or any container engine supporting [Alpine 3.14](https://wiki.alpinelinux.org/wiki/Release_Notes_for_Alpine_3.14.0)) to avoid unexpected `No such file or directory` errors (such as [\#214](https://github.com/asciidoctor/docker-asciidoctor/issues/214) or [\#215](https://github.com/asciidoctor/docker-asciidoctor/issues/215)).

</div>

<div class="note">

This image uses the Go-based [erd-go](https://github.com/kaishuu0123/erd-go/) instead of the original Haskell-based [erd](https://github.com/BurntSushi/erd) to allow the Docker image to be provided as a multi-platform image.

</div>

## How to use it

Just run:

    docker run -it -u $(id -u):$(id -g) -v <your directory>:/documents/ asciidoctor/docker-asciidoctor

or the following for [Podman](https://podman.io/):

    podman run -it -v <your directory>:/documents/ docker.io/asciidoctor/docker-asciidoctor

Docker/Podman maps your directory with */documents* directory in the container.

<div class="note">

You might need to add the option `:z` or `:Z` like `<your directory>:/documents/:z` or `<your directory>:/documents/:Z` if you are using SELinux. See [Docker docs](https://docs.docker.com/storage/bind-mounts/#configure-the-selinux-label) or [Podman docs](https://docs.podman.io/en/latest/markdown/podman-run.1.html#volume-v-source-volume-host-dir-container-dir-options).

</div>

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

-   To run AsciiDoc on an AsciiDoc file that contains latexmath and stem blocks:

        asciidoctor -r asciidoctor-mathematical sample-with-diagram.adoc
        asciidoctor-pdf -r asciidoctor-mathematical sample-with-diagram.adoc
        asciidoctor-epub3 -r asciidoctor-mathematical sample-with-diagram.adoc

-   To use Asciidoctor Confluence:

        asciidoctor-confluence --host HOSTNAME --spaceKey SPACEKEY --title TITLE --username USER --password PASSWORD sample.adoc

-   To use Asciidoctor reveal.js with local downloaded reveal.js:

        asciidoctor-revealjs sample-slides.adoc
        asciidoctor-revealjs -r asciidoctor-diagram sample-slides.adoc

-   To use Asciidoctor reveal.js with online reveal.js:

        asciidoctor-revealjs -a revealjsdir=https://cdnjs.cloudflare.com/ajax/libs/reveal.js/3.9.2 sample-slides.adoc
        asciidoctor-revealjs -a revealjsdir=https://cdnjs.cloudflare.com/ajax/libs/reveal.js/3.9.2 -r asciidoctor-diagram sample-slides.adoc

-   To convert files in batch:

        docker run --rm -u $(id -u):$(id -g) -v $(pwd):/documents/ asciidoctor/docker-asciidoctor asciidoctor-pdf index.adoc

    or:

        podman run --rm -v $(pwd):/documents/ docker.io/asciidoctor/docker-asciidoctor asciidoctor-pdf index.adoc

## How to contribute / do it yourself?

### Requirements

You need the following tools:

-   A bash compliant command line

-   [GNU make](http://man7.org/linux/man-pages/man1/make.1.html)

-   [Bats](https://github.com/sstephenson/bats) installed and in your bash PATH

-   Docker installed and in your path

-   [Trivy](https://github.com/aquasecurity/trivy) cli in case you want to scan images for vulnerabilities

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

### How to scan for vulnerabilities?

-   Trivy scans a docker image looking for software versions containing known vulnerabilities (CVEs).
    It’s always a good idea to scan the image to ensure no new issues are introduced.

-   Run the following command to replicate the repo’s `CVE Scan` pipeline on an image build locally.
    Note the pipeline runs nightly on the latest release version, so it can display issues solved in main branch.

        trivy image --severity HIGH,CRITICAL asciidoctor:latest

#### Deploy

The goal for deploying is to make the Docker image available with the correct Docker tag in Docker Hub.

As a matter of trust and transparency for the end-users, the image is rebuilt by Docker Hub itself by triggering a build.
This only works under the hypothesis of a minimalistic variation between the Docker build in the CI, and the Docker build by Docker Hub.

Deploying the image requires setting the following environment variables: `DOCKERHUB_SOURCE_TOKEN` and `DOCKERHUB_TRIGGER_TOKEN`.
Their values come from a Docker Hub trigger URL: `https://hub.docker.com/api/build/v1/source/${DOCKERHUB_SOURCE_TOKEN}/trigger/${DOCKERHUB_TRIGGER_TOKEN}/call/`.

You might want to set these variables as secret values in your CI to avoid any leaking in the output (as `curl` output for instance).
