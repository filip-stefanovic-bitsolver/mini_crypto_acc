#!/bin/bash
PROJDIR="$( cd "$( dirname -- "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

# Set the PROJDIR environment variable
export PROJDIR=$PROJDIR

# Print the PROJDIR environment variable to verify it's set correctly
echo $PROJDIR
