## docker-local-build-environment

##### Tired of endless installation and configuration .... ?! 

My personal solution is a local Build Environment with Jenkins (over 200 plugins), Gitlab, Sonar and Nexus; ready in a few minutes.
Your own lokal, personal, continous build enviroment (maybe in future releases I just call it lpcbe).

### System requirements
* At least 8GB Memory with 3GB Swap and 10GB Disk-Space
* docker version >= 17.06.0
* docker-compose version >= 1.15.0

## Installation
Bring up your own build environment ... just do a
```
   git clone https://github.com/Springjunky/docker-local-build-environment.git
   cd docker-local-build-environment
   sudo ./prepareCompose.sh 
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
 Sonar  http://<your-host-name>/sonar
 Nexus  http://<your-host-name>/nexus
 Gitlab  http://<your-host-name>/gitlab
```
#### Security
... not really, its all http .. don't worry about it! It's only local communication

WARNING
All the Services are reachable because docker creates and deletes dynamically FORWARD Rules with ACCEPT on startup / shutdown containers with exported ports.
To deny acccess froum outer world the DOCKER-USER Chain (since docker 17.06) ist the medium of choice.
A little Script to deny all access from outer world to your local build environment could be
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

iptables -F DOCKER-USER
iptables -F EXTERNAL-ACCESS-DENY
iptables -X EXTERNAL-ACCESS-DENY

iptables -N EXTERNAL-ACCESS-DENY
iptables -A EXTERNAL-ACCESS-DENY -j LOG --log-prefix "DCKR-EXT-ACCESS-DENY:" --log-level 6
iptables -A EXTERNAL-ACCESS-DENY -j DROP

iptables -A DOCKER-USER -i $EXTERNAL_INTERFACE -p tcp --match multiport --dports $PORTS_TO_BLOCK -j EXTERNAL-ACCESS-DENY 
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
|Sonar|admin|admin|
|Nexus   | admin | admin123 |
|Gitlab  | root  | gitlab4me |

## The Tools
### Jenkins

* MAVEN_HOME is /opt/maven
* JAVA_HOME is /usr/lib/jvm/java-8-openjdk-amd64
* Blue Ocean is installed and works perfect with a GitHUB Account, not GitLab ... sorry, this is Jenkins.
  You need to be logged in to use Blue Ocean

###  Giltab

* the docker-registry is at port 5555 (and secured with an openssl certificate ..thats part of 
  prepareCompose.sh), just create a project in gitlab and click at the  registry tab to show 
  how to login to the project registry and how to tag your images
* ssh cloning and pushing is at port 2222
 
#### gitlab-runner
The runner is a gitlab-multirunner image with a docker-runner (concurrent=1) , based on [gitlab/gitlab-runner][2]  The docker-compose section has an environment called
REGISTER_MODE, it can set to KEEP or REFRESH
* KEEP register at one time a runner and keep it during startups
* REFRESH at every startup remove all old runners and register one new runner (the pipeline-history ist lost.)

It takes a long time until gitlab is ready to accept a runner registration, if it fails, increase the REGISTER_TRYS



#### Jenkins and Gitlab

Gitlab is very very fast with new releases and sometimes the api has breaking changes. If something does not work take a look at the Jenkins Bugtracker.

### Sonar
You need to install some rules (Administration - System - Update Center - Available - Search: Java)

### Nexus
Some ToDo for me described here
[Unsecure docker-registry in Nexus][1]
use GitLab as a secured registry

..
And _yes_ docker-plugin in jenkins works (docker in docker, usefull but not recommended)


### My next steps

* give you some more preconfiguratiom
* ~~apply a gitlab runner~~
* apply git-lfs



[1]: https://support.sonatype.com/hc/en-us/articles/217542177-Using-Self-Signed-Certificates-with-Nexus-Repository-Manager-and-Docker-Daemon
[2]: https://hub.docker.com/r/gitlab/gitlab-runner/
