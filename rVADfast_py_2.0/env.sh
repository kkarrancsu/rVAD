#!/bin/bash

# enable module support
source /etc/profile.d/modules.sh
# sox with mp3 support
module load sox
# cuda10 is for PySpeech 3.2.x
module load cuda10.0/toolkit
# cuda10.1 is for torch-1.4
module load cuda10.1/toolkit
# for kaldi-gcc-5.4
module load gcc/5.4.0

export KALDI_ROOT=/home/hltcoe/jfarris/kaldi-gcc-5.4
export PYENV_ROOT=/home/hltcoe/kkarra/.conda/envs/ovad
