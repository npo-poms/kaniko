#!/bin/bash

$(dirname "${BASH_SOURCE[0]}")/local-setup.sh
cat job.env

KANIKO_SCRIPTS=$(dirname ${BASH_SOURCE[0]})/scripts/
. "$KANIKO_SCRIPTS"/script.sh