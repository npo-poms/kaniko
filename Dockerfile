FROM martizih/kaniko:v1.28.4-alpine@sha256:eeea1e5c64411dfc187f8b9b5d90677316fe8a33d99e61f02ccef97feaa70dcc


LABEL maintainer=poms@mmprogrami.nl
LABEL org.opencontainers.image.description='An extension of kaniko-project/executor that contains some script for deploying maven projects to CHP5 @ NPO'

ENV KANIKO_SCRIPTS=/ \
    TZ=Europe/Amsterdam
COPY scripts/*  $KANIKO_SCRIPTS

RUN apk update && apk add --no-cache util-linux-misc moreutils tzdata \
    && ln -snf /usr/share/zoneinfo/${TZ} /etc/localtime \
    && echo "${TZ}" > /etc/timezone

RUN  chmod +x ${KANIKO_SCRIPTS}script.sh

# This is default for docker, handy in gitlab when it is like that, so you don't need to specifiy it everytime
ENTRYPOINT ["/bin/sh", "-c"]
CMD ["sh"]