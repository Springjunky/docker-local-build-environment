### Steps to predownload plugins.

* Just a little wget Script to download all plugins
```
   ./preDownload.sh $(cat active-plugins.txt)
```
* Download jenkins-war-2.73.2.war to the actual directory

* Edit Dockerfile to copy all the Plugins into Jenkins
```
   Line: 107 - 115 before edit
    107 #------------------ Optional lokal caching of files
    108 # Download jenkins with yout favorite browser and put the war in the current dir.
    109 #COPY jenkins-war-2.73.2.war /usr/share/jenkins/jenkins.war
    110 ###### # Copy all Cached plugins ...
    111 # to preLoad all Plugins listed in active-plugins.txt use the command
    112 #  ./preDownload.sh $(cat active-plugins.txt)
    113 # this will download all the plugins in th Folder Plugins
    114 # COPY Plugins/* /usr/share/jenkins/ref/plugins/
    115 #------------------ Optional lokal caching of files end block

    Line: 107 - 115 after edit (edit only line 109 and 114)
    107 #------------------ Optional lokal caching of files
    108 # Download jenkins with yout favorite browser and put the war in the current dir.
    
    109 COPY jenkins-war-2.73.2.war /usr/share/jenkins/jenkins.war
    
    110 ###### # Copy all Cached plugins ...
    111 # to preLoad all Plugins listed in active-plugins.txt use the command
    112 #  ./preDownload.sh $(cat active-plugins.txt)
    113 # this will download all the plugins in th Folder Plugins
    
    114 COPY Plugins/* /usr/share/jenkins/ref/plugins/
    
    115 #------------------ Optional lokal caching of files end block

```

    
