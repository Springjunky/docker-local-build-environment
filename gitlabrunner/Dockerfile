FROM gitlab/gitlab-runner

# The giltab multirunner ist an officila Image by gitlab 

ADD entrypointAutoregister /
RUN chmod +x /entrypointAutoregister

ENTRYPOINT ["/usr/bin/dumb-init", "/entrypointAutoregister"]

CMD ["run", "--user=gitlab-runner", "--working-directory=/home/gitlab-runner"]


