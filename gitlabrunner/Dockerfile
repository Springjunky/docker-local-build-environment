FROM gitlab/gitlab-runner:v12.0.1

# The giltab multirunner ist an officila Image by gitlab 

ADD entrypointAutoregister /
RUN chmod +x /entrypointAutoregister

ENTRYPOINT ["/usr/bin/dumb-init", "/entrypointAutoregister"]

CMD ["run", "--user=gitlab-runner", "--working-directory=/home/gitlab-runner"]


