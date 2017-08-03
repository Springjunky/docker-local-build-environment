FROM ubuntu:17.04
ENV DEBIAN_FRONTEND noninteractive
ENV JAVA_VERSION=8 \
    JAVA_UPDATE=131 \
    JAVA_BUILD=11 \
    JAVA_HOME="/usr/lib/jvm/default-jvm"
# update dpkg repositories and install tools
RUN apt-get update 
RUN apt-get install -y openjdk-8-jdk 
RUN apt-get install -y --no-install-recommends apt-utils
RUN apt-get install -y git 
RUN apt-get install -y wget
RUN apt-get install -y curl
RUN apt-get install -y graphviz

ENV JAVA_HOME /usr/lib/jvm/java-8-openjdk-amd64

# This is the line for the Jenkins prefix to set ... remember
# to set the location in the  reverse-proxy.conf
ENV JENKINS_OPTS="--webroot=/var/cache/jenkins/war --prefix=/jenkins"

#-----------------------------------------------
#  install Oracle Java if you want ... and 
#  remove the line "RUN apt-get install -y openjdk-8-jdk"
#  above ... but openjdk is pretty good ! 
#-----------------------------------------------
#------------ Download
# ## ENV filename jdk-8u131-linux-x64.tar.gz
# ## ENV downloadlink http://download.oracle.com/otn-pub/java/jdk/${JAVA_VERSION}u${JAVA_UPDATE}-b${JAVA_BUILD}/d54c1d3a095b4ff2b6607d096fa80163/jdk-${JAVA_VERSION}u${JAVA_UPDATE}-linux-x64.tar.gz
# ## RUN   wget --no-cookies --header "Cookie: oraclelicense=accept-securebackup-cookie" -O /tmp/$filename $downloadlink 
# ----  unpack java
# ## ENV UNPACK_DIR=jdk1.8.0_131/
# ## RUN mkdir -p /opt/  && tar -zxf /tmp/$filename -C /opt/ && ln -s /opt/${UNPACK_DIR} /opt/java
# ## ENV JAVA_HOME /opt/java
#----------------------------------------
#  install Maven
#----------------------------------------
# get maven 3.2.0
RUN wget --no-verbose -O /tmp/apache-maven-3.2.5.tar.gz http://archive.apache.org/dist/maven/maven-3/3.2.5/binaries/apache-maven-3.2.5-bin.tar.gz
# verify checksum
RUN echo "b2d88f02bd3a08a9df1f0b0126ebd8dc /tmp/apache-maven-3.2.5.tar.gz" | md5sum -c
# install maven
RUN tar xzf /tmp/apache-maven-3.2.5.tar.gz -C /opt/
RUN ln -s /opt/apache-maven-3.2.5 /opt/maven
ENV MAVEN_HOME /opt/maven
ENV PATH $MAVEN_HOME/bin:$JAVA_HOME/bin:$PATH

RUN apt-get update && apt-get install -y  zip unzip
RUN rm -rf /opt/java/src.zip && rm -rf /tmp/$filename 
RUN rm -f /tmp/apache-maven-3.2.5.tar.gz
#------------------------------
# install Jenkins
#------------------------------
ENV JENKINS_HOME /var/jenkins_home
ENV JENKINS_SLAVE_AGENT_PORT 50000
ARG user=jenkins
ARG group=jenkins
ARG uid=1000
ARG gid=1000
# Jenkins is run with user `jenkins`, uid = 1000
# If you bind mount a volume from the host or a data container, 
# ensure you use the same uid
RUN groupadd -g ${gid} ${group} && useradd -d "$JENKINS_HOME" -u ${uid} -g ${gid} -m -s /bin/bash ${user}
# Jenkins home directory is a volume, so configuration and build history 
# can be persisted and survive image upgrades

VOLUME /var/jenkins_home 

# `/usr/share/jenkins/ref/` contains all reference configuration we want 
# to set on a fresh new installation. Use it to bundle additional plugins 
# or config file with your custom jenkins Docker image.
RUN mkdir -p /usr/share/jenkins/ref/init.groovy.d && mkdir /tmp
ENV TINI_VERSION 0.14.0
ENV TINI_SHA 6c41ec7d33e857d4779f14d9c74924cab0c7973485d2972419a3b7c7620ff5fd
# Use tini as subreaper in Docker container to adopt zombie processes 
RUN curl -fsSL https://github.com/krallin/tini/releases/download/v${TINI_VERSION}/tini-static-amd64 -o /bin/tini && chmod +x /bin/tini \
  && echo "$TINI_SHA  /bin/tini" | sha256sum -c -

COPY init.groovy /usr/share/jenkins/ref/init.groovy.d/tcp-slave-agent-port.groovy

# jenkins version being bundled in this docker image 
ARG JENKINS_VERSION
ENV JENKINS_VERSION ${JENKINS_VERSION:-2.71}

# jenkins.war checksum, download will be validated using it
ARG JENKINS_SHA=71b2b5ba6d7fca261325682639ba604b7b889e7e

# Can be used to customize where jenkins.war get downloaded from http://updates.jenkins-ci.org/download/war/2.57/jenkins.war
ARG JENKINS_URL=https://repo.jenkins-ci.org/public/org/jenkins-ci/main/jenkins-war/${JENKINS_VERSION}/jenkins-war-${JENKINS_VERSION}.war

# could use ADD but this one does not check Last-Modified header neither does it allow to control checksum 
# see https://github.com/docker/docker/issues/8331
RUN curl -fsSL ${JENKINS_URL} -o /usr/share/jenkins/jenkins.war && echo "${JENKINS_SHA}  /usr/share/jenkins/jenkins.war" | sha1sum -c -


ENV JENKINS_UC https://updates.jenkins.io
RUN chown -R ${user} "$JENKINS_HOME" /usr/share/jenkins/ref

# for main web interface:
EXPOSE 8080

ENV COPY_REFERENCE_FILE_LOG $JENKINS_HOME/copy_reference_file.log

USER ${user}

COPY jenkins-support /usr/local/bin/jenkins-support
COPY jenkins.sh /usr/local/bin/jenkins.sh

ENV JAVA_OPTIONS="-Djava.awt.headless=true -Dhudson.security.csrf.requestfield=crumb"


ENTRYPOINT ["/bin/tini", "--", "/usr/local/bin/jenkins.sh"]
#-----------------------------------------------
# get all Plugins from existing Jenins
#-----------------------------------------------
# JENKINS_HOST=username:password@myhost.com:port
# curl -sSL "http://$JENKINS_HOST/pluginManager/api/xml?depth=1&xpath=/*/*/shortName|/*/*/version&wrapper=plugins" | perl -pe 's/.*?<shortName>([\w-]+).*?<version>([^<]+)()(<\/\w+>)+/\1 \2\n/g'|sed 's/ /:/'


# ----------------------------------------------------
COPY plugins.sh /usr/local/bin/plugins.sh
COPY install-plugins.sh /usr/local/bin/install-plugins.sh
# Install additional plugins
COPY plugins.txt /usr/share/jenkins/ref/
RUN /usr/local/bin/plugins.sh /usr/share/jenkins/ref/plugins.txt





USER root

RUN apt-get clean




