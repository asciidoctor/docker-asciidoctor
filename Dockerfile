FROM fedora
MAINTAINER Guillaume Scheibel <guillaume.scheibel@gmail.com>

RUN yum install -y tar make gcc ruby ruby-devel rubygems graphviz rubygem-nokogiri asciidoctor
RUN (curl -s -k -L -C - -b "oraclelicense=accept-securebackup-cookie" http://download.oracle.com/otn-pub/java/jdk/8u20-b26/jdk-8u20-linux-x64.tar.gz | tar xfz -)
ENV JAVA_HOME /jdk1.8.0_20
ENV PATH $PATH:$JAVA_HOME/bin:/fopub/bin
ENV BACKENDS /asciidoctor-backends
# Install fopub and run it once on a fake file to download the gradle wrapper
RUN mkdir /fopub && curl -L https://api.github.com/repos/asciidoctor/asciidoctor-fopub/tarball | tar xzf - -C /fopub/ --strip-components=1 && \
    touch empty.xml && fopub empty.xml && rm empty.xml

RUN gem install --no-ri --no-rdoc asciidoctor-diagram && \
    gem install --no-ri --no-rdoc asciidoctor-epub3 --version 1.0.0.alpha.2 && \
    gem install --no-ri --no-rdoc asciidoctor-pdf --version 1.5.0.alpha.7 && \
    gem install --no-ri --no-rdoc asciidoctor-confluence && \
    gem install --no-ri --no-rdoc coderay pygments.rb thread_safe epubcheck kindlegen && \
    gem install --no-ri --no-rdoc slim && \
    gem install --no-ri --no-rdoc haml tilt && \
    mkdir /documents && \
    mkdir $BACKENDS && \
    (curl -LkSs https://api.github.com/repos/asciidoctor/asciidoctor-backends/tarball | tar xfz - -C $BACKENDS --strip-components=1)

# Install blockdiag, seqdiag, actdiag and nwdiag diagram tools
RUN yum install -y wget python-devel zlib-devel
RUN wget https://bitbucket.org/pypa/setuptools/raw/bootstrap/ez_setup.py -O - | python
RUN easy_install "blockdiag[pdf]"
RUN easy_install seqdiag
RUN easy_install actdiag
RUN easy_install nwdiag

WORKDIR /documents
VOLUME /documents

CMD ["/bin/bash"]
