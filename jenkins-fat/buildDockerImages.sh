. ../.env
docker build --build-arg JENKINS_LTS_VERSION=$JENKINS_LTS --tag jenkins-fat --file Dockerfile .
