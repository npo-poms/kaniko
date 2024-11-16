#!/bin/bash

. $(dirname "${BASH_SOURCE[0]}")/local-setup.sh

KANIKO_SCRIPTS=$(dirname ${BASH_SOURCE[0]})/scripts/
. "$KANIKO_SCRIPTS"/script.sh