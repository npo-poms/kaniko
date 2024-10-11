FROM gcr.io/kaniko-project/executor:debug

LABEL maintainer=poms@mmprogrami.nl

COPY kaniko-gitlab.sh /
COPY docker-build-setup.sh /

RUN chmod +x /kaniko-gitlab.sh && \
  chmod +x /docker-build-setup.sh

ENTRYPOINT ["/kaniko-gitlab.sh"]