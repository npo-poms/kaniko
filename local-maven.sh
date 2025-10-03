#!/bin/bash

DIR=$(dirname "${BASH_SOURCE[0]}")
KANIKO_SCRIPTS=$DIR/scripts/
JOB_ENV=${JOB_ENV:-'job.env'}

. $DIR/local-setup.sh

if [[ "$JOB_ENV" != "NO" ]]; then
  cat $JOB_ENV
fi

. "$KANIKO_SCRIPTS"/script.sh