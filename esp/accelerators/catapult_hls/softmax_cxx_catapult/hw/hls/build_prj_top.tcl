# Copyright (c) 2011-2021 Columbia University, System Level Design Group
# SPDX-License-Identifier: Apache-2.0

array set opt {
    # The 'csim' flag enables C simulation.
    # The 'hsynth' flag enables HLS.
    # The 'rtlsim' flag enables RTL simulation.
    # The 'lsynth' flag enables logic synthesis.
    # The 'debug' flag stops Catapult HLS before the architect step.
    # The 'hier' flag enables an implementation with hierarchical blocks.
    csim       1
    hsynth     1
    rtlsim     1
    lsynth     0
    debug      0
    hier       1
}

source ../../../common/hls/common.tcl
source ./build_prj.tcl
