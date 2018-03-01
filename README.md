## docker-local-build-environment

##### Tired of endless installation and configuration .... ?!

My personal solution is a local, docker-based CI/CD Build Environment ready in a few minutes to offer you a reade-to-use convinience playground with
* Jenkins 
  * open-jdk
  * maven
  * ansible
  * docker
* Gitlab 
  * and a docker based gitlab-runner registrated
  * secured docker-registry ready (openssh certificate)
  * push with ssh avialable at port 2222
* Nexus 3
* Sonar
* Keykloak (as Single Sign On or JWT playground)
* Postgres (used by Sonar, Keycloak and YOUR applications)
* Standard Docker-Registry V2 with a simple UI 



so you can be your own local "DevOp"; nearly every category of [periodic table of devoptools][4] has one tool in your local setup. 

## This is NOT for any cluster (Swarm/Kubernetes)

### System requirements
* At least 8GB Memory with 3GB Swap and 10GB Disk-Space
* docker version >= 17.06.0
* docker-compose version >= 1.15.0

#### Listenports to be claimed

|Port  |  Why  |
|---|---|
|80 |NGINX, forwards requests ton internal docker-containers   |
|5432 |postgres standard connection port |
|2222 |ssh port of gitlab, used to push via ssh connection ssh://git@myHOST:2222/scott/foo.git |
|5555 |Gitlab docker-registry secured with GitLab credentials |
|5000 |Standard Docker-Registry v2 not secured|

If your change the ports in the docker-compose.yml change them also in nginx-reverse/nginx.conf (stream {...} )
## Installation
### without sonar
Bring up your own DevOp Playground  ... just do a
```
   git clone https://github.com/Springjunky/docker-local-build-environment.git
   cd docker-local-build-environment
   sudo ./setupEnvironment.sh
   docker-compose up --build -d
   docker-compose logs
```

### with sonar and/or Keycloak
Warning: you need a lot of memory to use the full toolset (more than 10GB)
```
   git clone https://github.com/Springjunky/docker-local-build-environment.git
   cd docker-local-build-environment
   sudo ./setupEnvironment.sh

   # Sonar only
   docker-compose  -f docker-compose.yml -f docker-compose-sonar.yml up --build

   # Sonar AND Keycloak
   docker-compose  -f docker-compose.yml -f docker-compose-sonar.yml -f docker-compose-keycloak.yml up --build

   # Keycloak only
   docker-compose  -f docker-compose.yml -f docker-compose-keycloak.yml up --build
   
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
 Sonar  http://<your-host-name>/sonar
 Keycloak http://<your-host-name>/auth
 Docker-Registry-Ui: http://<your-host-name>/regweb 
 Postgres: At standard listenport 5432 for your jdbc-connection-string 
           stream-passthrough to postgres-container.
```

#### Security
... not really, its all http .. don't worry about it! It's only local communication

##### security paranoia
See Readme in folder security-paranoia if you want to have some hints how to configure your firewall.

### Logins and Passwords
|Image  |  User  |  Password |
|---|---|---|
|Jenkins| admin| admin |
|Nexus   | admin | admin123 |
|Gitlab  | root  | gitlab4me |
|Sonar | admin | admin |
|Keycloak|admin|admin|
|Postgres|postgres|admin|

## The Tools
There are some configurations you have to do after setup.
*Remember:* At every time use your real hostname and NOT localhost (locahost inside a container is the container itself).
For example: If yuo configure a GitLab-Connection in Jenkins, you will reach Gitlab at http://&lt;you host&gt;/gitlab and not http://localhost/gitlab
### Jenkins
* MAVEN_HOME is /opt/maven
* JAVA_HOME is /usr/lib/jvm/java-8-openjdk-amd64
* Blue Ocean is installed if you choose (M)uch mor plugins and works perfect with a GitHUB Account, not GitLab ... sorry, this is Jenkins.
  You need to be logged as a jenkins-user to use Blue Ocean

###  Giltab
* the docker-registry from GitLab is at port 5555 (and secured with an openssl certificate ..thats part of
  setupEnvironment.sh), just create a project in gitlab and click at the registry tab to show
  how to login to the project registry and how to tag your images and upload them.
* ssh cloning and pushing is at port 2222 (ssh://git@myHOST:2222/scott/foo.git remeber to upload your public key before, should be ~/.ssh/id_rsa.pub )

#### gitlab-runner
The runner is a gitlab-multirunner image with a docker-runner (concurrent=1) , based on [gitlab/gitlab-runner][2]  at every startup any runner is removed and only ONE new runner is registrated to avoid multiple runners  (the pipeline-history maybe lost.) docker-in-docker works :-)

It takes a long time until gitlab is ready to accept a runner registration, if it fails, increase the REGISTER_TRYS in docker-compse.yml


#### Jenkins and Gitlab

Gitlab is very very fast with new releases and sometimes the api has breaking changes. If something does not work take a look at the Jenkins Bugtracker.

### Sonar
You need to install some rules (Administration - System - Update Center - Available - Search: Java)

### Keycloak
There is a testproject in folder spring-boot-keycloak-sample, it is a standard Spring-Boot which you can start with
```
mv spring-boot:run
``` 
Use your browser and navigate to the "landing-page" at http://<your host>:8081 the "My products" link will redirect you to Keycloak (must be setup with settings from [this tutorial][3], but use your *REAL* hostname, not _localhost_ as Valid Redirect URI's )
_tl;dr_
* login as user:admin, password:admin
* create realm "springboot"
* create client "product-app" as openid-connect client with Valid Redirect URI's  http://&lt;your host&gt;:8081/*
* create role "user"
* create user "testuser" and map the role "user" to testuser (tab Role Mappings)


### Postgres
You can use any tool to connect to the database at localhost:5432 this is a pass through to the container so any
JDBC-Connection should work

### The Docker-Registries
* NEXUS-Docker-Registry ist NOT configured .. needs a pass trough and some more configs, see [Unsecure docker-registry in Nexus][1] feel free to provide a push-request
* GitLab docker-registry is at port 5555 you have to use your GitLab Credentials from the corresponding git-respository
* standard Docker-Registry v2 ist at standard port 5000 with no credentials, so eays-to-use


## Troubleshooting
##### check Hostname and IP
In most cases a wrong HOSTNAME:HOSTIP causes trouble, to check this try the following.
* log into the jenkins-fat container (with id)
```
  docker container ls
  docker container exec -it jenkins-fat bash
  chmod a+rw /tmp
  apt-get update
  apt-get install -y --allow-unauthenticated iputils-ping
  ping jenkins
  ping gitlab
  ping <your local hostname>
```
every ping must work, if not, check the .env file, is there the correct DC_HOSTNAME / DC_HOSTIP ?

##### changed interface ip ?
  If you change your network (switching between home/office/lan/wifi) your ip-address
  could be change and the container is not able to resolve your host any more
  Check the .env file or just run the setup-Script again. 

##### consider low memory:
  with an amount lower than 8GB sonar and embedded eleastic search did not startup and no message is displayed

##### too many plugins to download:
  You can do an "pre download of the plugins", see the readme.md at jenkins-fat direcory


### My next steps

* give you some more preconfiguration
* ~~install docker~~
* ~~install docker-compose~~
* ~~install ansible~~
* ~~apply a gitlab runner~~
* ~~apply git-lfs~~
* ~~apply sonar~~
* ~~apply keycloak~~
* ~~apply a better registry~~



[1]: https://support.sonatype.com/hc/en-us/articles/217542177-Using-Self-Signed-Certificates-with-Nexus-Repository-Manager-and-Docker-Daemon
[2]: https://hub.docker.com/r/gitlab/gitlab-runner/
[3]: https://developers.redhat.com/blog/2017/05/25/easily-secure-your-spring-boot-applications-with-keycloak/
[4]: https://xebialabs.com/periodic-table-of-devops-tools/
