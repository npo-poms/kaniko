FROM martizih/kaniko:v1.28.3-alpine@sha256:38e3516bcd3ba2646ffdfc06c724c55b3f8b5e6228ebca59b7550b8080c46c17


LABEL maintainer=poms@mmprogrami.nl
LABEL org.opencontainers.image.description='An extension of kaniko-project/executor that contains some script for deploying maven projects to CHP5 @ NPO'

ENV KANIKO_SCRIPTS=/
COPY scripts/*  $KANIKO_SCRIPTS

RUN apk update && apk add --no-cache util-linux-misc moreutils

RUN  chmod +x ${KANIKO_SCRIPTS}script.sh

# This is default for docker, handy in gitlab when it is like that, so you don't need to specifiy it everytime
ENTRYPOINT ["/bin/sh", "-c"]
CMD ["sh"]