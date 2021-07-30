#!/bin/bash

# source local environment settings
source env.sh

# check for necessary environment variable, typically set in an env.sh
[ -z "$KALDI_ROOT" ] && echo "Missing KALDI_ROOT environment variable!" && exit 1
[ -z "$PYENV_ROOT" ] && echo "SCALE20_PYENV_ROOT environment variable!" && exit 1

# check for certain binaries as secondary check
[ ! -z "$KALDI_ROOT" ] && [ ! -f $KALDI_ROOT/src/featbin/compute-mfcc-feats ] && echo "KALDI_ROOT does not seem to point to a valid location!" && exit 1
#[ ! -z "$PYENV_ROOT" ] && [ ! -f $PYENV_ROOT/bin/stm-utils ] && echo "SCALE20_PYENV_ROOT does not seem to point to a valid location!" && exit 1

[ -f $KALDI_ROOT/tools/env.sh ] && . $KALDI_ROOT/tools/env.sh

export PATH=:$PYENV_ROOT/bin:$KALDI_ROOT/src/bin:$PWD:$PATH

# TODO: do we need this???
#[ ! -f $KALDI_ROOT/tools/config/common_path.sh ] && echo >&2 "The standard file $KALDI_ROOT/tools/config/common_path.sh is not present -> Exit!" && exit 1
#source $KALDI_ROOT/tools/config/common_path.sh
# 

# kaldi sorting order
export LC_ALL=C
