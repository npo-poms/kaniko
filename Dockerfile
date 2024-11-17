FROM gcr.io/kaniko-project/executor:debug

LABEL maintainer=poms@mmprogrami.nl

LABEL org.opencontainers.image.description='An extension of kaniko-project/executor that contains some script for deploying maven projects to CHP5 @ NPO'

ENV KANIKO_SCRIPTS=/
COPY scripts/*  $KANIKO_SCRIPTS

RUN  chmod +x ${KANIKO_SCRIPTS}script.sh

ENTRYPOINT [""]