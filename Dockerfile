ARG BASE_REGISTRY=registry1.dso.mil
ARG BASE_IMAGE=ironbank/redhat/ubi/ubi8
ARG BASE_TAG=8.5
FROM ${BASE_REGISTRY}/${BASE_IMAGE}:${BASE_TAG}
ARG ATLAS_VERSION=2.2.0

RUN yum update
RUN yum upgrade
RUN yum -y install java-1.8.0-openjdk-devel python3 wget patch unzip procps ncurses lsof
RUN alternatives --set python /usr/bin/python3
RUN cd /usr/local \
    && wget https://www-eu.apache.org/dist/maven/maven-3/3.6.3/binaries/apache-maven-3.6.3-bin.tar.gz \
    && tar -xzvf apache-maven-3.6.3-bin.tar.gz \
    && ln -s apache-maven-3.6.3 apache-maven \
    && cd /tmp \
    && wget https://dlcdn.apache.org/atlas/${ATLAS_VERSION}/apache-atlas-${ATLAS_VERSION}-sources.tar.gz \
    && mkdir -p /tmp/atlas-src \
    && tar --strip 1 -xzvf apache-atlas-${ATLAS_VERSION}-sources.tar.gz -C /tmp/atlas-src \
    && rm apache-atlas-${ATLAS_VERSION}-sources.tar.gz

COPY buildtools.patch /tmp/atlas-src

RUN cd /tmp/atlas-src \
    && patch pom.xml buildtools.patch

RUN cd /tmp/atlas-src \
    && export JAVA_HOME="/etc/alternatives/java_sdk_1.8.0_openjdk" \
    && export M2_HOME="/usr/local/apache-maven" \
    && export MAVEN_HOME="/usr/local/apache-maven" \
    && export PATH=${M2_HOME}/bin:${PATH} \
    && export MAVEN_OPTS="-Xms2g -Xmx2g" \
    && mvn clean -Dmaven.repo.local=/tmp/.mvn-repo -Dhttps.protocols=TLSv1.2 -DskipTests package -Pdist,embedded-hbase-solr \
    && tar -xzvf /tmp/atlas-src/distro/target/apache-atlas-${ATLAS_VERSION}-server.tar.gz -C /opt \
    && rm -Rf /tmp/atlas-src \
    && rm -Rf /tmp/.mvn-repo

VOLUME ["/opt/apache-atlas-${ATLAS_VERSION}/conf", "/opt/apache-atlas-${ATLAS_VERSION}/logs"]

COPY atlas_start.py.patch atlas_config.py.patch /opt/apache-atlas-${ATLAS_VERSION}/bin/

RUN cd /opt/apache-atlas-${ATLAS_VERSION}/bin \
    && patch -b -f < atlas_start.py.patch \
    && patch -b -f < atlas_config.py.patch

COPY atlas-env.sh /opt/apache-atlas-${ATLAS_VERSION}/conf/atlas-env.sh

#RUN cd /opt/apache-atlas-${ATLAS_VERSION} \
#    && ./bin/atlas_start.py -setup || true

#RUN cd /opt/apache-atlas-${ATLAS_VERSION} \
#    && ./bin/atlas_start.py & \
#    touch /opt/apache-atlas-${ATLAS_VERSION}/logs/application.log \
#    && tail -f /opt/apache-atlas-${ATLAS_VERSION}/logs/application.log | sed '/AtlasAuthenticationFilter.init(filterConfig=null)/ q' \
#    && sleep 10 \
#    && python3 /opt/apache-atlas-${ATLAS_VERSION}/bin/atlas_stop.py

COPY ./entrypoint.sh /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]
