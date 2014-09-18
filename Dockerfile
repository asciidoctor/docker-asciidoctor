FROM fedora
MAINTAINER Guillaume Scheibel <guillaume.scheibel@gmail.com>

RUN (curl -s -k -L -C - -b "oraclelicense=accept-securebackup-cookie" http://download.oracle.com/otn-pub/java/jdk/8u20-b26/jdk-8u20-linux-x64.tar.gz | tar xfz -)
ENV JAVA_HOME /jdk1.8.0_20
ENV PATH $PATH:$JAVA_HOME/bin

RUN yum install -y make gcc ruby ruby-devel rubygems graphviz rubygem-nokogiri && \
    gem install --no-ri --no-rdoc asciidoctor asciidoctor-diagram thread_safe epubcheck kindlegen && \
    gem install --no-ri --no-rdoc asciidoctor-epub3 --version 1.5.0.alpha.2 && \
    gem install --no-ri --no-rdoc asciidoctor-pdf --version 1.5.0.alpha.5 && \
    gem install --no-ri --no-rdoc coderay pygments.rb && \
    mkdir /documents

WORKDIR /documents
VOLUME /documents

CMD ["/bin/bash"]
