#!/bin/bash

# Copyright    2017  Vimal Manohar
# Apache 2.0

# To be run from .. (one directory up from here)
# see ../run.sh for example

# Compute rVAD on a Kaldi directory

nj=4
cmd=run.pl

echo "$0 $@"  # Print the command line for logging

if [ -f path.sh ]; then . ./path.sh; fi
. parse_options.sh || exit 1;

if [ $# -lt 1 ] || [ $# -gt 3 ]; then
   echo "Usage: $0 [options] <data-dir> [<log-dir> [<vad-dir>]]";
   echo "e.g.: $0 data/train exp/make_vad mfcc"
   echo "Note: <log-dir> defaults to <data-dir>/log, and <vad-dir> defaults to <data-dir>/data"
   echo " Options:"
   echo "  --nj <nj>                                        # number of parallel jobs"
   echo "  --cmd (utils/run.pl|utils/queue.pl <queue opts>) # how to run jobs."
   exit 1;
fi

data=$1
if [ $# -ge 2 ]; then
  logdir=$2
else
  logdir=$data/log
fi
if [ $# -ge 3 ]; then
  vaddir=$3
else
  vaddir=$data/rvad
fi


# make $vaddir an absolute pathname.
vaddir=`perl -e '($dir,$pwd)= @ARGV; if($dir!~m:^/:) { $dir = "$pwd/$dir"; } print $dir; ' $vaddir ${PWD}`

# use "name" as part of name of the archive.
name=`basename $data`

mkdir -p $vaddir || exit 1;
mkdir -p $logdir || exit 1;

if [ -f $vaddir/vad.scp ]; then
  mkdir -p $vaddir/.backup
  echo "$0: moving $vaddir/vad.scp to $vaddir/.backup"
  mv $vaddir/vad.scp $vaddir/.backup
fi

utils/split_data.sh $data $nj || exit 1;
sdata=$data/split$nj;

$cmd JOB=1:$nj $logdir/vad_${name}.JOB.log \
  rvad_fast.sh $sdata/JOB/wav.scp \
  $vaddir/vad_${name}.JOB.ark $vaddir/vad_${name}.JOB.scp || exit 1

for ((n=1; n<=nj; n++)); do
  cat $vaddir/vad_${name}.$n.scp || exit 1;
done > $vaddir/vad.scp

echo "Created rVAD output for $name"
