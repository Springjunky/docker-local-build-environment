## docker-local-build-environment

##### Tired of endless installation and configuration .... ?!

My personal solution is a local Build Environment with Jenkins, Gitlab / Gitlabrunner, (Sonar) and Nexus; ready in a few minutes.
Your own lokal, personal, continous build enviroment (maybe in future releases I just call it lpcbe).

#### This is NOT for any cluster (Swarm / Kubernetes)

### System requirements
* At least 8GB Memory with 3GB Swap and 10GB Disk-Space
* docker version >= 17.06.0
* docker-compose version >= 1.15.0

## Installation
Bring up your own build environment ... just do a
```
   git clone https://github.com/Springjunky/docker-local-build-environment.git
   cd docker-local-build-environment
   sudo ./setupEnvironment.sh
   docker-compose up --build -d
   docker-compose logs
```
### The first startup takes a long time (especially gitlab), so be patient

open your favorite browser (_not_ at localhost, use the $(hostname)/jenkins )
to prevent jenkins spit out "your reverse proxy is wrong")

### Ready !

Now you are ready to go with a little CI/CD Environment:
```
 Jenkins  http://<your-host-name>/jenkins
 Nexus  http://<your-host-name>/nexus
 Gitlab  http://<your-host-name>/gitlab
 in the next Release:  Sonar  http://<your-host-name>/sonar
```
#### Security
... not really, its all http .. don't worry about it! It's only local communication

##### security paranoia
All the exposed ports are reachable from outer world because docker creates and deletes dynamically iptables FORWARD rules with default policy ACCEPT on startup/shutdown containers wich have exported ports.

To deny acccess from outer world the DOCKER-USER Chain (since docker 17.06) ist the medium of choice for your own rules (this is the first target in the FORWARD-Chain and never touched by docker).

A little Script to deny all access from outer world to your local build environment could be the following (exposed port from nginx are 80,5555,2222)
```
#!/bin/bash
if [ $# -lt 1 ] ; then
  echo "Need your external interface as one parameter"
  echo "Common names are eth0, enp...,"
  echo "List of your names"
  ifconfig -a | sed 's/[ \t].*//;/^\(lo\|\)$/d'
  exit
fi

PORTS_TO_BLOCK="80,5555,2222"
EXTERNAL_INTERFACE=$1

# Flush and delete custom Chains
iptables -F DOCKER-USER
iptables -F EXTERNAL-ACCESS-DENY
iptables -X EXTERNAL-ACCESS-DENY

# Create a  log-and-drop Chain
iptables -N EXTERNAL-ACCESS-DENY
iptables -A EXTERNAL-ACCESS-DENY -j LOG --log-prefix "DCKR-EXT-ACCESS-DENY:" --log-level 6
iptables -A EXTERNAL-ACCESS-DENY -j DROP

# Block all incomming traffic for docker
iptables -A DOCKER-USER -i $EXTERNAL_INTERFACE \
         -p tcp --match multiport \
         --dports $PORTS_TO_BLOCK \
         -j EXTERNAL-ACCESS-DENY

# Restore default rule to return all the rest back to the FORWARD-Chain
iptables -A DOCKER-USER -j RETURN

echo "Rules created "
iptables -v -L DOCKER-USER
iptables -v -L EXTERNAL-ACCESS-DENY
echo "See logs with prefix DCKR-EXT-ACCESS-DENY:"
```


### Logins and Passwords

|Image  |  User  |  Password |
|---|---|---|
|Jenkins| admin| admin |
|Nexus   | admin | admin123 |
|Gitlab  | root  | gitlab4me |

## The Tools
### Jenkins

* MAVEN_HOME is /opt/maven
* JAVA_HOME is /usr/lib/jvm/java-8-openjdk-amd64
* Blue Ocean is installed if you choose (M)uch mor plugins and works perfect with a GitHUB Account, not GitLab ... sorry, this is Jenkins.
  You need to be logged as a jenkins-user to use Blue Ocean

###  Giltab

* the docker-registry from GitLab is at port 5555 (and secured with an openssl certificate ..thats part of
  prepareEnvironment.sh), just create a project in gitlab and click at the  registry tab to show
  how to login to the project registry and how to tag your images
* ssh cloning and pushing is at port 2222

#### gitlab-runner
The runner is a gitlab-multirunner image with a docker-runner (concurrent=1) , based on [gitlab/gitlab-runner][2]  at every startup any runner is removed and only ONE new runner ist registrated to avoid multiple runners  (the pipeline-history maybe lost.) docker-in-docker works :-)

It takes a long time until gitlab is ready to accept a runner registration, if it fails, increase the REGISTER_TRYS in docker-compse.yml


#### Jenkins and Gitlab

Gitlab is very very fast with new releases and sometimes the api has breaking changes. If something does not work take a look at the Jenkins Bugtracker.

### Sonar
In future releases Sonar will be added...(You need to install some rules (Administration - System - Update Center - Available - Search: Java)

### Nexus
Some ToDo for me described here
[Unsecure docker-registry in Nexus][1]
use GitLab as a secured registry

..
And _yes_ docker-plugin in jenkins works (docker in docker, usefull but not recommended)

## Troubleshooting

In most cases a wrong HOSTNAME:HOSTIP causes trouble, to check this try the follwing.
* log into the jenkins-fat container (with id)
```
  docker container ls
  docker container exec -it dockerlocalbuildenvironment_jenkins-fat_1 bash
  apt-get update
  apt-get install -y --allow-unauthenticated iputils-ping
  ping google.de
  ping jenkins-fat
  ping gitlab
  ping <your local hostname>
```
every ping must work, if not, check extra_hosts in compose-file

* consider low memory:
  with an amount lower than 8GB sonar and eleastic search did not startup

* too many plugins to download:
  You can do an "pre download of the plugins", see the readme.md at jenkins-fat direcory


### My next steps

* give you some more preconfiguration
* ~~install docker~~
* ~~install docker-compose~~
* ~~install ansible~~
* ~~apply a gitlab runner~~
* ~~apply git-lfs~~
* apply sonar
* apply a better registry



[1]: https://support.sonatype.com/hc/en-us/articles/217542177-Using-Self-Signed-Certificates-with-Nexus-Repository-Manager-and-Docker-Daemon
[2]: https://hub.docker.com/r/gitlab/gitlab-runner/
