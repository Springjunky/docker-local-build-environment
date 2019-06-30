#!/bin/bash

function pause(){
   read -p "Press [Enter] key to continue..."
}

if [ $(id -u) -gt 0 ] ;then
    echo "Use sudo $0 "
    exit 1
fi

echo "Prepare .env for compose file and directorys"

#------------------- Defaults 
JENKINS_LTS=2.176.1
USER_DATA_DIR=$HOME/devstack-data
HOSTNAME=$(hostname)
HOSTIP=$(hostname -I | awk '{print $1}' )


echo "########################################################################"
echo "Verify your hostname and the ip is correct, if this is wrong the  "
echo "container network ist not able to lookup the host \"$(hostname) \" by name "
echo "it's a docker-Feature !!"
echo "the \"routing \" ist out of container an back into the nginx and forward to container:-)       "
echo " and 8.8.8.8 (Google Nameserver) does not known your internal hostname  "
echo "########################################################################"

pause

echo "--------------------------------------------------------------"
echo "------------------ Host-Settings -----------------------------"
echo "--------------------------------------------------------------"

read -e -p "Your hostname (hit return if $HOSTNAME is correct) : " -i $HOSTNAME GIVEN_HOSTNAME
echo "Setting HOSTNAME to $GIVEN_HOSTNAME"
HOSTNAME=$GIVEN_HOSTNAME
echo "Type your hostIP, I guess it is one of $(hostname -I) "
echo "Remember, 127.0.0.1 is NOT the correct IP and the docker-Network starts with 172.x.y.z and is also not correct"
read -e -p "Your hostIP  : " -i $HOSTIP GIVEN_HOSTIP
HOSTIP=$GIVEN_HOSTIP
echo "Setting HOSTIP to $GIVEN_HOSTIP"
echo " "

echo "--------------------------------------------------------------"
echo "------------------ Jenkins ----- -----------------------------"
echo "--------------------------------------------------------------"
read -e -p "Please enter your Jenkins-Version (2.176.1) : " -i $JENKINS_LTS GIVEN_JENKINS_VERSION
echo "Number of plugins to download for Jenkins ${JENKINS_LTS_MAJOR}.${JENKINS_LTS_MINOR}.${JENKINS_LTS_BUILD} "
echo "  (L)et _ME_ choose (0 Plugins)"
echo "  (P)redonwload Plugins (defined in ./jenkins-fat/plugins.txt) "
PLUGINS=P
read -e -p "Choose L or P : " -i $PLUGINS GIVEN_PLUGINS


# Set the right volume-names, hostname and host_ip in .env for docker-compose.yml
echo "---------- generating .env file for docker-compose.yml "

# this enivonment file is sourced by the preDownload.sh script in jenkins-fat
cat .env.template > .env
echo "DC_HOSTNAME=${HOSTNAME}" >> .env
echo "DC_HOSTIP=${HOSTIP}" >> .env
echo "DC_BASE_DATA_DIR=${USER_DATA_DIR}" >> .env
echo "JENKINS_LTS_MAJOR=$(echo $GIVEN_JENKINS_VERSION | cut -d. -f1)" >> .env
echo "JENKINS_LTS_MINOR=$(echo $GIVEN_JENKINS_VERSION | cut -d. -f2)" >> .env
echo "JENKINS_LTS_BUILD=$(echo $GIVEN_JENKINS_VERSION | cut -d. -f3)" >> .env
echo "JENKINS_LTS=$(echo $GIVEN_JENKINS_VERSION | cut -d. -f1).$(echo $GIVEN_JENKINS_VERSION | cut -d. -f2)" >> .env
case $GIVEN_PLUGINS in 
      "L"|"l" )
      echo "Pluigns for Jenkins  ${JENKINS_LTS_MAJOR}.${JENKINS_LTS_MINOR}.${JENKINS_LTS_BUILD} is your choice"
      ;;
      "P"|"p")
      echo "..start Donloading and cache Plugins to ./jenkins-fat/Plugins/${JENKINS_LTS_MAJOR}.${JENKINS_LTS_MINOR}"
      pause
      cd jenkins-fat 
      . preDownload.sh  
      cd -
      ;;
esac

echo "--------------------------------------------------------------"
echo "------------------ ssl ---------------------------------------"
echo "--------------------------------------------------------------"

type openssl 2>/dev/null
if [ $? -eq 0 ] ; then
  echo "openssl installed :-)"
else
  echo "please install openssl first"
  exit 1
fi

#----------------------------------
echo "create need host-volumes"
mkdir -p $USER_DATA_DIR/sonar/sonarqube_conf
mkdir -p $USER_DATA_DIR/jenkins
mkdir -p $USER_DATA_DIR/gitlab/config/ssl
mkdir -p $USER_DATA_DIR/gitlab-runner
mkdir -p $USER_DATA_DIR/nexus
mkdir -p $USER_DATA_DIR/docker-registry/images
chown -R 200 $USER_DATA_DIR/nexus
chmod -R a+rw $USER_DATA_DIR


#----------------------------------

echo "Create a self-signed certificate for your host: $HOSTNAME to prevent docker complaining unsecure (gitlab) registry "
pause

if [ -f $USER_DATA_DIR/gitlab/config/ssl/$(hostname).key ]; then
  FILE_NAME=$USER_DATA_DIR/gitlab/config/ssl/$(hostname).key-$(date +"%F-%H-%M-%S-%N")
  cp $USER_DATA_DIR/gitlab/config/ssl/$(hostname).key $USER_DATA_DIR/gitlab/config/ssl/$(hostname).key-$(date +"%F-%H-%M-%S-%N")
  echo "previous key  saved as $FILE_NAME"
fi
if [ -f $USER_DATA_DIR/gitlab/config/ssl/$(hostname).crt ]; then
  FILE_NAME=$USER_DATA_DIR/gitlab/config/ssl/$(hostname).crt-$(date +"%F-%H-%M-%S-%N")
  cp $USER_DATA_DIR/gitlab/config/ssl/$(hostname).crt $USER_DATA_DIR/gitlab/config/ssl/$(hostname).crt-$(date +"%F-%H-%M-%S-%N")
  echo "previous crt  saved as $FILE_NAME"
fi

# Key and Cert only need for the docker-registry to "save" push your images to gitlab
openssl req -x509 -nodes -days 3650 -newkey rsa:2048 \
     -keyout $USER_DATA_DIR/gitlab/config/ssl/$(hostname).key \
     -out $USER_DATA_DIR/gitlab/config/ssl/$(hostname).crt \
     -subj "/C=DE/ST=Home/L=Home/O=Local/OU=CI\/CD-Build-Stack/CN=$(hostname)"

if [ $? -eq 0 ] ;then
  echo "----------- Your certificate used by Gitlab docker-registry@${HOSTNAME} -------------------"
  openssl x509 -in $USER_DATA_DIR/gitlab/config/ssl/$(hostname).crt -text | head -15
  echo "-------------------------------------------------------------------------------------------"
  pause
else
  echo "NO CERT GENERATED "
  exit 1
fi

if [ -f .env ]; then
  FILE_NAME=.env-$(date +"%F-%H-%M-%S-%N")
  cp .env $FILE_NAME
  echo "previous .env saved as $FILE_NAME"
fi
# Copy preconfigs to host-volumes
# sonar.properties
if [ -f $USER_DATA_DIR/sonar/sonarqube_conf/sonar.properties ] ; then
  echo "WARNING: $USER_DATA_DIR/sonar/sonarqube_conf/sonar.properties exists"
  echo "make sure it has a sonar.web.context=/sonar entry"
else
  cp preconfig/sonar/sonar.properties $USER_DATA_DIR/sonar/sonarqube_conf
fi

#Copy and modify predefined Jobs and Configs
cp -r preconfig/jenkins/* $USER_DATA_DIR/jenkins/

# Copy Registry Config
cp preconfig/docker-registry/config.yml $USER_DATA_DIR/docker-registry/config.yml

chmod a+rw .env
echo "---------------------------------------------------------------"
echo "------------------ generated Environment for Docker-Compose ---"
echo "---------------------------------------------------------------"

echo "---------- generated file  ---------------------------- "

cat .env
echo "-------------------------------------------------------------------------------------------"
echo "If something changed (your IP / hostname ... ) just edit the .env or rerun the script."

echo "-------------------------------------------------------------------------------------------"
echo "-------------------------------------------------------------------------------------------"
echo "Environment for docker-compose.yml created"
echo " "
echo "use the following URL"
BASE_URL="http://"$(hostname)"/"
echo "Jenkins:            ${BASE_URL}jenkins"
echo "Nexus  :            ${BASE_URL}nexus"
echo "Gitlab :            ${BASE_URL}gitlab"
echo "Docker-Registry-Ui: ${BASE_URL}regweb"
echo "Sonar:              ${BASE_URL}sonar (optional)"
echo "Keycloak:           ${BASE_URL}auth (optional)"
echo "Feel free to provide push-requests :-)"
pause 
echo " "

echo "Setup finished, just type the following commands to start and see the logs of your environment"
echo " "
echo "Without Sonar and Keycloak: docker-compose up --build -d "
echo "Full Toolset              : docker-compose -f docker-compose.yml -f docker-compose-sonar.yml -f docker-compose-keycloak.yml up --build -d"
echo "docker-compose logs -f"
echo " " 
echo "be patient ...10 docker-containers needs time to start up " 






