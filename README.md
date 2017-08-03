## docker-local-build-environment

##### Tired of endless installation and configuration .... ?! 

My personal solution is a local Build Environment with Jenkins full of plugins and sonar; ready in 60sec. with a
lokal, personal, continous build enviroment (maybe in future releses I just call it lpcbe).



Bring up your own build environment ... just do a
```
   https://github.com/Springjunky/docker-local-build-environment.git
   cd docker-local-build-environment
   docker-compose up -d
   docker-compose logs 
```
open your favorite browser (_not_ at localhost, use [http://<your-fq-hostname>] to prevent jenkins spit out "your reverse proxy is wrong")
and cut and paste the jenkins first startup access-token.

### Ready !

Now you are ready to go with a little CI Environment and Sonar code-quality check.

Jenkins resides under http://<your-host-name>/jenkins
Sonar resides under http://<your-host-name>/sonar

After docker ist up you only have to configure your tools in Jenkins
..
And _yes_ docker-plugin in jenkins works (docker in docker, usefull but not recommended)


### My next steps

* Pump up the Image with latest docker and ansible
* move the personal DNS-Server outsite the docker-compose (ENV)

