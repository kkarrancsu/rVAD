from __future__ import division
import numpy 
import pickle
import os
import sys
import math
import code
from scipy.signal import lfilter
import speechproc
from copy import deepcopy

import argparse
import kaldi_io

# Refs:
#  [1] Z.-H. Tan, A.k. Sarkara and N. Dehak, "rVAD: an unsupervised segment-based robust voice activity detection method," Computer Speech and Language, 2019. 
#  [2] Z.-H. Tan and B. Lindberg, "Low-complexity variable frame rate analysis for speech recognition and voice activity detection." 
#  IEEE Journal of Selected Topics in Signal Processing, vol. 4, no. 5, pp. 798-807, 2010.

# 2017-12-02, Achintya Kumar Sarkar and Zheng-Hua Tan


def process_scp(wav_fp, vad_ark, vad_scp):

    vad_output = 'ark:| copy-feats --compress=true ark:- ark,scp:%s,%s' % (vad_ark, vad_scp)

    with kaldi_io.open_or_fd(vad_output, 'wb') as f_out:
        with open(wav_fp, 'r') as f_in:
            while True:
                line = f_in.readline()
                if not line:
                    break
                line = line.strip()
                l_split = line.split()
                f_id = l_split[0]
                f_path = l_split[1]

                compute_rVad(f_path, f_id, f_out)


def compute_rVad(fin_wav, fin_key, output_fobj):
    winlen, ovrlen, pre_coef, nfilter, nftt = 0.025, 0.01, 0.97, 20, 512
    ftThres=0.5; vadThres=0.4
    opts=1

    # finwav=str(sys.argv[1])
    # fvad=str(sys.argv[2])

    fs, data = speechproc.speech_wave(fin_wav)
    ft, flen, fsh10, nfr10 =speechproc.sflux(data, fs, winlen, ovrlen, nftt)

    # --spectral flatness --
    pv01=numpy.zeros(nfr10)
    pv01[numpy.less_equal(ft, ftThres)]=1
    pitch=deepcopy(ft)

    pvblk=speechproc.pitchblockdetect(pv01, pitch, nfr10, opts)

    # --filtering--
    ENERGYFLOOR = numpy.exp(-50)
    b=numpy.array([0.9770,   -0.9770])
    a=numpy.array([1.0000,   -0.9540])
    fdata=lfilter(b, a, data, axis=0)

    #--pass 1--
    noise_samp, noise_seg, n_noise_samp=speechproc.snre_highenergy(fdata, nfr10, flen, fsh10, ENERGYFLOOR, pv01, pvblk)

    #sets noisy segments to zero
    for j in range(n_noise_samp):
        fdata[range(int(noise_samp[j,0]),  int(noise_samp[j,1]) +1)] = 0

    vad_seg=speechproc.snre_vad(fdata,  nfr10, flen, fsh10, ENERGYFLOOR, pv01, pvblk, vadThres)

    # numpy.savetxt(fvad, vad_seg.astype(int),  fmt='%i')
    # print("%s --> %s " %(finwav, fvad))
    kaldi_io.write_vec_flt(output_fobj, vad_seg, key=fin_key)


if __name__ == '__main__':
    parser = argparse.ArgumentParser()
    parser.add_argument('wav_scp', type=str,
                        help='Input wav.scp file to process')
    parser.add_argument('vad_ark', type=str,
                        help='Output ark file to store vad results')  # output dir
    parser.add_argument('vad_scp', type=str,
                        help='Output SCP file to store vad results')  # output dir
    args = parser.parse_args()
