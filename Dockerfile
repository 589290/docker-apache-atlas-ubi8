ARG BASE_REGISTRY=registry1.dso.mil
ARG BASE_IMAGE=ironbank/redhat/ubi/ubi8
ARG BASE_TAG=8.5
FROM ${BASE_REGISTRY}/${BASE_IMAGE}:${BASE_TAG}
ARG ATLAS_VERSION=3.0.0-SNAPSHOT
ARG MAVEN_VERSION=3.8.4

RUN yum -y update
RUN yum -y upgrade
RUN yum -y install java-1.8.0-openjdk-devel python3 wget patch unzip procps ncurses lsof hostname git
RUN alternatives --set python /usr/bin/python3
RUN cd /usr/local \
    && wget https://www-eu.apache.org/dist/maven/maven-3/${MAVEN_VERSION}/binaries/apache-maven-${MAVEN_VERSION}-bin.tar.gz \
    && tar -xzvf apache-maven-${MAVEN_VERSION}-bin.tar.gz \
    && ln -s apache-maven-${MAVEN_VERSION} apache-maven \
    && cd /tmp \
    && git clone https://github.com/apache/atlas.git

RUN cd /tmp/atlas \
    && export JAVA_HOME="/etc/alternatives/java_sdk_1.8.0_openjdk" \
    && export M2_HOME="/usr/local/apache-maven" \
    && export MAVEN_HOME="/usr/local/apache-maven" \
    && export PATH=${M2_HOME}/bin:${PATH} \
    && export MAVEN_OPTS="-Xms2g -Xmx2g" \
    && mvn clean -Dmaven.repo.local=/tmp/.mvn-repo -Dhttps.protocols=TLSv1.2 -DskipTests package -Pdist,embedded-hbase-solr \
    && tar -xzvf /tmp/atlas/distro/target/apache-atlas-${ATLAS_VERSION}-server.tar.gz -C /opt \
    && rm -Rf /tmp/atlas \
    && rm -Rf /tmp/.mvn-repo \
    && cd /opt \
    && mv -f apache-atlas-${ATLAS_VERSION} atlas

VOLUME ["/opt/atlas"]

COPY ./atlas-env.sh /opt/atlas/conf/atlas-env.sh
COPY ./cmd.sh /cmd.sh
CMD /cmd.sh
