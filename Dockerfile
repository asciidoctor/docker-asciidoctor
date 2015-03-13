FROM fedora
MAINTAINER Guillaume Scheibel <guillaume.scheibel@gmail.com>

RUN yum install -y tar make gcc ruby ruby-devel rubygems graphviz rubygem-nokogiri asciidoctor
RUN (curl -s -k -L -C - -b "oraclelicense=accept-securebackup-cookie" http://download.oracle.com/otn-pub/java/jdk/8u20-b26/jdk-8u20-linux-x64.tar.gz | tar xfz -)
RUN mkdir /fopub && curl -L https://api.github.com/repos/asciidoctor/asciidoctor-fopub/tarball | tar xzf - -C /fopub/ --strip-components=1
ENV JAVA_HOME /jdk1.8.0_20
ENV PATH $PATH:$JAVA_HOME/bin:/fopub/bin
ENV BACKENDS /asciidoctor-backends

RUN gem install --no-ri --no-rdoc asciidoctor-diagram && \
    gem install --no-ri --no-rdoc asciidoctor-epub3 --version 1.0.0.alpha.2 && \
    gem install --no-ri --no-rdoc asciidoctor-pdf --version 1.5.0.alpha.5 && \
    gem install --no-ri --no-rdoc asciidoctor-confluence && \
    gem install --no-ri --no-rdoc coderay pygments.rb thread_safe epubcheck kindlegen && \
    gem install --no-ri --no-rdoc slim && \
    mkdir /documents && \
    mkdir $BACKENDS && \
    (curl -LkSs https://api.github.com/repos/asciidoctor/asciidoctor-backends/tarball | tar xfz - -C $BACKENDS --strip-components=1)

WORKDIR /documents
VOLUME /documents

CMD ["/bin/bash"]
