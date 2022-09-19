# Copyright (c) Microsoft Corporation.
# Licensed under the MIT License.

set -x

# MSCCL source directory.
export MSCCL_SRC_DIR="/mnt/msccl"

# NPKit source directory.
export NPKIT_SRC_DIR="/mnt/npkit"

# Path to nccl-tests binary being profiled.
export NCCL_TEST_BIN="/mnt/nccl-tests/build/all_reduce_perf"
# export NCCL_TEST_BIN="/mnt/nccl-tests/build/alltoall_perf"

# NPKit runtime directory, used to store logs and results.
export NPKIT_RUN_DIR="/mnt/npkit_run"

# Message size of MSCCL operation.
export MSCCL_MSG_SIZE="16K"

# MSCCL communication algorithm. Ring, Tree and MSCCL are supported.
export MSCCL_ALGO="Ring,MSCCL"
# export MSCCL_ALGO="Tree,MSCCL"

# MSCCL communication protocol. Simple and LL are supported.
# export MSCCL_PROTO="Simple"
export MSCCL_PROTO="LL"
# export MSCCL_PROTO="LL128"

# Number of nccl-tests warmups.
export MSCCL_NUM_WARMUPS="0"

# Number of nccl-tests iterations.
export MSCCL_NUM_ITERS="10"

bash npkit_runner.sh
