FROM gcr.io/kaniko-project/executor:debug

LABEL maintainer=poms@mmprogrami.nl

LABEL org.opencontainers.image.description='An extension of kaniko-project/executor that contains some script for deploying maven projects to CHP5 @ NPO'


COPY scripts/*  /

RUN chmod +x /kaniko-gitlab.sh && \
  chmod +x /docker-build-setup.sh && \
    chmod +x /script.sh

ENTRYPOINT ["/script.sh"]