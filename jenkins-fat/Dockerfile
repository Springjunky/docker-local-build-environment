FROM ubuntu:19.04
ENV DEBIAN_FRONTEND noninteractive
ENV JAVA_VERSION=8 \
    JAVA_UPDATE=131 \
    JAVA_BUILD=11 \
    JAVA_HOME="/usr/lib/jvm/default-jvm"

# update dpkg repositories and install tools
RUN apt-get update
#--------------------------------------------
#------------ Open JDK
RUN apt-get install -y openjdk-8-jdk
#--------------------------------------------
#------------ Tools for Jenkins and apt-get to use SSL Repositorys
RUN apt-get install -y --no-install-recommends apt-utils git wget curl graphviz \
    apt-transport-https ca-certificates software-properties-common gpg-agent zip unzip
#-----------------------------------------------
#---------------  Ansible
#-----------------------------------------------
RUN  apt-add-repository ppa:ansible/ansible 2>/dev/null
RUN  apt-get update  &&  apt-get -y install ansible
#--------------------------------------------
#------------ Docker
#--------------------------------------------
RUN echo 
RUN curl -fsSL https://download.docker.com/linux/ubuntu/gpg > docker-public-key && \
    apt-key add docker-public-key && \
    rm docker-public-key 
RUN add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) edge test" && \
     apt-get update && apt-get install -y docker-ce
#--------------------------------------------
#------------ Docker Compose
#--------------------------------------------
RUN curl -o /usr/bin/docker-compose -L \
    "https://github.com/docker/compose/releases/download/1.21.2/docker-compose-$(uname -s)-$(uname -m)" \
    && chmod +x /usr/bin/docker-compose

#--------------------------------------------
#------------ Jenkins with jdk-8
#--------------------------------------------

ENV JAVA_HOME /usr/lib/jvm/java-8-openjdk-amd64

# This is the line for the Jenkins prefix to set to get access with nginx and a 
# comfortable path like http://<yourhost>/jenins... remember
# to set the location in the  reverse-proxy.conf if you change this

ENV JENKINS_OPTS="--webroot=/var/cache/jenkins/war --prefix=/jenkins"
ENV GIT_SSL_NO_VERIFY=1
#----------------------------------------
#  Maven
#----------------------------------------
RUN wget --no-verbose -O /tmp/apache-maven-3.5.3.tar.gz \
          http://archive.apache.org/dist/maven/maven-3/3.5.3/binaries/apache-maven-3.5.3-bin.tar.gz
# verify checksum and install maven
RUN echo "51025855d5a7456fc1a67666fbef29de /tmp/apache-maven-3.5.3.tar.gz" | md5sum -c && \
    tar xzf /tmp/apache-maven-3.5.3.tar.gz -C /opt/ && ln -s /opt/apache-maven-3.5.3 /opt/maven
    
ENV MAVEN_HOME /opt/maven
ENV PATH $MAVEN_HOME/bin:$JAVA_HOME/bin:$PATH

RUN rm -rf /opt/java/src.zip && \
    rm -rf /tmp/$filename && \
    rm -f  /tmp/apache-maven-3.5.3.tar.gz


#------------------------------
# install Jenkins
#------------------------------
ENV JENKINS_HOME /var/jenkins_home
ENV JENKINS_SLAVE_AGENT_PORT 50000
ARG user=jenkins
ARG group=jenkins
ARG uid=1000
ARG gid=1000
# Jenkins is run with user `jenkins`, uid = 1000 If you bind mount a volume from the host or a data container,  ensure you use the same uid
RUN groupadd -g ${gid} ${group} && useradd -d "$JENKINS_HOME" -u ${uid} -g ${gid} -m -s /bin/bash ${user}
# Jenkins home directory is a volume, so configuration and build history
# can be persisted and survive image upgrades

RUN mkdir -p /usr/share/jenkins/ref/init.groovy.d && mkdir /tmp

VOLUME /var/jenkins_home

ENV TINI_VERSION 0.18.0
ENV TINI_SHA eadb9d6e2dc960655481d78a92d2c8bc021861045987ccd3e27c7eae5af0cf33
# Use tini as subreaper in Docker container to adopt zombie processes
RUN curl -fsSL https://github.com/krallin/tini/releases/download/v${TINI_VERSION}/tini-static-amd64 -o /bin/tini && chmod +x /bin/tini \
  && echo "$TINI_SHA  /bin/tini" | sha256sum -c -

# jenkins version being bundled in this docker image
# This is the latest stable version define in file ../.env
ARG JENKINS_LTS_VERSION
RUN echo JENKINS_LTS_VERSION=${JENKINS_LTS_VERSION}

#### jenkins.war checksum, download will be validated using it
ARG JENKINS_URL=http://updates.jenkins-ci.org/download/war/${JENKINS_LTS_VERSION}/jenkins.war
# could use ADD but this one does not check Last-Modified header neither does it allow to control checksum  see https://github.com/docker/docker/issues/8331
RUN echo Download from ${JENKINS_URL} && curl -fL ${JENKINS_URL} -o /usr/share/jenkins/jenkins.war 

###### # Copy all Cached plugins ...
COPY Plugins/${JENKINS_LTS_VERSION}/* /usr/share/jenkins/ref/plugins/

ENV JENKINS_UC https://updates.jenkins.io
ENV JENKINS_UC_EXPERIMENTAL=https://updates.jenkins.io/experimental
RUN chown -R ${user} "$JENKINS_HOME" /usr/share/jenkins/ref

# for main web interface, reversed-proxied by nginx
EXPOSE 8080
ENV COPY_REFERENCE_FILE_LOG $JENKINS_HOME/copy_reference_file.log
USER ${user}
COPY jenkins-support /usr/local/bin/jenkins-support
COPY jenkins.sh /usr/local/bin/jenkins.sh
ENV JAVA_OPTIONS="-Djava.awt.headless=true -Dhudson.security.csrf.requestfield=crumb -Djenkins.install.runSetupWizard=false"

ENTRYPOINT ["/bin/tini", "--", "/usr/local/bin/jenkins.sh"]
#-------------------------------------------------------------------------
# if you need a list of all your actual plugins use this to 
# get all Plugins from an existing Jenins without Version (latest is used)
#--------------------------------------------------------------------------
# JENKINS_HOST=username:password@myhost.com:port
# curl -sSL "http://$JENKINS_HOST/pluginManager/api/xml?depth=1&xpath=/*/*/shortName|/*/*/version&wrapper=plugins" | \
#  perl -pe 's/.*?<shortName>([\w-]+).*?<version>([^<]+)()(<\/\w+>)+/\1 \2\n/g'|sed 's/ /:/ ' | awk -F: '{ print $1 }' | sort'
# ----------------------------------------------------
# Prevent Setup Wizard .. all Plugins copied before
RUN echo ${JENKINS_LTS_VERSION}  > /usr/share/jenkins/ref/jenkins.install.UpgradeWizard.state
RUN echo ${JENKINS_LTS_VERSION} > /usr/share/jenkins/ref/jenkins.install.InstallUtil.lastExecVersion

USER root

RUN apt-get clean autoremove && rm -rf /var/lib/apt/lists/*
