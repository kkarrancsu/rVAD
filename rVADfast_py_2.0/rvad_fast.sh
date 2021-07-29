#!/bin/bash

wav_scp=$1
vad_ark=$2
vad_scp=$3

# wrapper for calling python script to compute rvad
source activate xvec
python rVAD_fast_kaldi.py $wav_scp $vad_ark $vad_scp