
. ../.env

mkdir -p Plugins/${JENKINS_LTS}
chmod -R a+rwx Plugins/${JENKINS_LTS}

#TODO: Download Jenkins.war

 
for datei in $(cat plugins.txt)
do
  if test -e Plugins/${JENKINS_LTS}/${datei}.hpi
  then
    echo "Already downloaded ${datei} "
  else
    echo -n "Download  ${datei}.hpi"
    wget -q -P Plugins/${JENKINS_LTS} https://updates.jenkins.io/${JENKINS_LTS}/latest/${datei}.hpi
    chmod  a+rw Plugins/${JENKINS_LTS}/${datei}.hpi
    if [ $? -eq 0 ] ; then
      echo "  OK"
    else
      # Without quiet to show what happened
      wget -P Plugins/${JENKINS_LTS} https://updates.jenkins.io/${JENKINS_LTS}/latest/${datei}.hpi
    fi      
  fi
done



