FROM martizih/kaniko:v1.28.1-alpine


LABEL maintainer=poms@mmprogrami.nl
LABEL org.opencontainers.image.description='An extension of kaniko-project/executor that contains some script for deploying maven projects to CHP5 @ NPO'

ENV KANIKO_SCRIPTS=/
COPY scripts/*  $KANIKO_SCRIPTS

RUN apk update && apk add --no-cache util-linux-misc moreutils

RUN  chmod +x ${KANIKO_SCRIPTS}script.sh

# This is default for docker, handy in gitlab when it is like that, so you don't need to specifiy it everytime
ENTRYPOINT ["/bin/sh", "-c"]
CMD ["sh"]