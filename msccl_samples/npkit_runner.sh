# Copyright (c) Microsoft Corporation.
# Licensed under the MIT License.

set -x

# Function that runs msccl-tests-nccl and collect NPKit traces.
# msccl_test
#   <nccl_test_bin> <msg_size> <algorithm> <protocol> <num_warmups> <num_iters>
#   <npkit_dump_dir> <npkit_result_dir>
function msccl_test() {
  mpirun --allow-run-as-root \
    -map-by ppr:8:node --bind-to numa \
    -x LD_PRELOAD=$2/build/lib/libnccl.so:$LD_PRELOAD \
    -x NCCL_DEBUG=WARN \
    -x NCCL_ALGO=$4 \
    -x NCCL_PROTO=$5 \
    -x NPKIT_DUMP_DIR=$8 \
    $1 -b $3 -e $3 -f 2 -g 1 -c 1 -w $6 -n $7 | tee $9/log.txt
}

# Tag of this NPKit run.
npkit_run_tag=`basename ${NCCL_TEST_BIN}`"/${msg_size}/${MSCCL_ALGO}/${MSCCL_PROTO}"

# Path to NPKit dump directory.
npkit_dump_dir="${NPKIT_RUN_DIR}/npkit_dump/${npkit_run_tag}"

# Path to NPKit post-process directory.
npkit_trace_dir="${NPKIT_RUN_DIR}/npkit_trace/${npkit_run_tag}"

# Path to NPKit result directory.
npkit_result_dir="${NPKIT_RUN_DIR}/npkit_result/${npkit_run_tag}"

# Build MSCCL with NPKit
cd ${MSCCL_SRC_DIR}
make clean
make -j src.build NPKIT_FLAGS="${NPKIT_FLAGS}"

# Clean existing results
rm -rf ${NPKIT_RUN_DIR}
mkdir -p ${npkit_dump_dir}
mkdir -p ${npkit_trace_dir}
mkdir -p ${npkit_result_dir}

# Run NPKit on all nodes.
msccl_test ${NCCL_TEST_BIN} ${MSCCL_SRC_DIR} ${MSCCL_MSG_SIZE} ${MSCCL_ALGO} ${MSCCL_PROTO} ${MSCCL_NUM_WARMUPS} ${MSCCL_NUM_ITERS} ${npkit_dump_dir} ${npkit_result_dir}

# Generate trace file
cd ${NPKIT_SRC_DIR}/msccl_samples
python3 npkit_trace_generator.py --npkit_dump_dir=${npkit_dump_dir} --npkit_event_header_path=${MSCCL_SRC_DIR}/src/include/npkit/npkit_event.h --output_dir=${npkit_trace_dir}
cd ${npkit_trace_dir}
tar cvzf npkit_result.tar.gz npkit_event_trace.json
mv npkit_result.tar.gz ${npkit_result_dir}
