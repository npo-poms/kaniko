FROM gcr.io/kaniko-project/executor:debug

LABEL maintainer=poms@mmprogrami.nl

COPY scripts/*  /

RUN chmod +x /kaniko-gitlab.sh && \
  chmod +x /docker-build-setup.sh && \
    chmod +x /script.sh

ENTRYPOINT ["/script.sh"]