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
   https://github.com/Springjunky/docker-local-build-environment.git
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

### Logins and Passwords

|Image  |  User  |  Password |
|---|---|---|
|Jenkins| admin| admin |
|Sonar|admin|admin|
|Nexus   | admin | admin123 |
|Gitlab  | root  | choosen Password |

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
* apply a gitlab runner
* apply git-lfs



[1]: https://support.sonatype.com/hc/en-us/articles/217542177-Using-Self-Signed-Certificates-with-Nexus-Repository-Manager-and-Docker-Daemon
