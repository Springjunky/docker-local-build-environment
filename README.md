## docker-local-build-environment

A local Build Environment with Jenkins full of plugins and sonar


Bring up your own build environment ... just do a
```
   docker-compose build && docker-compose up
```

and you are ready to go with a little CI Environment an Code-quality check.

Jenins resides under http://<your-host-name>/jenkins
Sonar resides under http://<your-host-name>/sonar

After docker ist up you only have to configure your tools in Jenkins
..

And _yes_ docker-plugin in jenkins works (docker in docker)


### My next steps

Pump up the Image with latest docker and ansible.
