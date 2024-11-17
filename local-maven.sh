#!/bin/bash

DIR=$(dirname "${BASH_SOURCE[0]}")
KANIKO_SCRIPTS=$DIR/scripts/

. $DIR/local-setup.sh

cat job.env

. "$KANIKO_SCRIPTS"/script.sh