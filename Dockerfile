FROM gcr.io/kaniko-project/executor:debug

LABEL maintainer=poms@mmprogrami.nl

COPY kaniko-gitlab.sh /

RUN chmod +x /kaniko-gitlab.sh

ENTRYPOINT ["/kaniko-gitlab.sh"]