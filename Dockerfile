FROM fedora
MAINTAINER Guillaume Scheibel <guillaume.scheibel@gmail.com>

RUN (curl -s -k -L -C - -b "oraclelicense=accept-securebackup-cookie" http://download.oracle.com/otn-pub/java/jdk/8u20-b26/jdk-8u20-linux-x64.tar.gz | tar xfz -)
ENV JAVA_HOME /jdk1.8.0_20
ENV PATH $PATH:$JAVA_HOME/bin

RUN yum install -y make gcc ruby ruby-devel rubygems graphviz && \
    gem install asciidoctor asciidoctor-diagram&& \
    gem install --pre asciidoctor-pdf && \
    gem install coderay pygments.rb thread_safe && \
    mkdir /documents

WORKDIR /documents
VOLUME /documents

CMD ["/bin/bash"]
