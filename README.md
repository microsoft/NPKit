## Introduction

NPKit (NCCL Profiling Kit) is a joint profiler framework for NCCL/RCCL. It enables users to insert customized profiling events into different NCCL/RCCL components, especially into giant NCCL/RCCL GPU kernels. These events are then automatically placed onto a unified timeline in [Google Trace Event Format](https://docs.google.com/document/d/1CvAClvFfyA5R-PhYUmn5OOQtYMH4h6I0nSsKchNAySU/preview), which users can then leverage trace viewer to understand NCCL/RCCL's workflow and performance.

NPKit is easy to use. It's designed to be run with all kinds of NCCL/RCCL workloads. Users only need to insert their profiling events into NCCL/RCCL, replace existing NCCL/RCCL with NPKit-enabled version, run their workload that leverages NCCL/RCCL, and the unified timeline with profiling events are automatically generated.

NPKit is lightweight. During each run, users can choose to only enable profiling events they care about to minimize overhead caused by NPKit.

## Build

NPKit is a patches series of some version of NCCL/RCCL. Users need to apply these patches to correct NCCL/RCCL version and build NCCL/RCCL with expected profiling events specified. In this section, we take NCCL 2.10.3-1 and RCCL develop branch commit 4643a17 as examples. Assume we want to jointly profile LL128 data transfer time in GPU and net send/recv time in CPU:

Build NPKit for NCCL v2.10.3-1:

        $ git clone https://github.com/nvidia/nccl nccl-v2.10.3-1
        $ cd nccl-v2.10.3-1
        $ git checkout 7e51592
        $ find ../npkit_for_nccl_v2.10.3-1/ | grep '.diff$' | awk '{print "git apply "$1}' | bash
        $ make -j src.build NPKIT_FLAGS="-DENABLE_NPKIT -DENABLE_NPKIT_EVENT_TIME_SYNC_CPU -DENABLE_NPKIT_EVENT_TIME_SYNC_GPU -DENABLE_NPKIT_EVENT_PRIM_LL128_DATA_PROCESS_ENTRY -DENABLE_NPKIT_EVENT_PRIM_LL128_DATA_PROCESS_EXIT -DENABLE_NPKIT_EVENT_NET_SEND_ENTRY -DENABLE_NPKIT_EVENT_NET_SEND_EXIT -DENABLE_NPKIT_EVENT_NET_RECV_ENTRY -DENABLE_NPKIT_EVENT_NET_RECV_EXIT"

Build NPKit for RCCL develop branch 4643a17:

        $ git clone https://github.com/rocmsoftwareplatform/rccl rccl-develop-4643a17
        $ cd rccl-develop-4643a17
        $ git checkout 4643a17
        $ find ../npkit_for_rccl_develop_4643a17/ | grep '.diff$' | awk '{print "git apply "$1}' | bash
        $ mkdir build
        $ cd build
        $ CXX=/opt/rocm/bin/hipcc cmake -DNPKIT_FLAGS="-DENABLE_NPKIT -DENABLE_NPKIT_EVENT_TIME_SYNC_CPU -DENABLE_NPKIT_EVENT_TIME_SYNC_GPU -DENABLE_NPKIT_EVENT_PRIM_LL128_DATA_PROCESS_ENTRY -DENABLE_NPKIT_EVENT_PRIM_LL128_DATA_PROCESS_EXIT -DENABLE_NPKIT_EVENT_NET_SEND_ENTRY -DENABLE_NPKIT_EVENT_NET_SEND_EXIT -DENABLE_NPKIT_EVENT_NET_RECV_ENTRY -DENABLE_NPKIT_EVENT_NET_RECV_EXIT" ..
        $ make -j

Note that we use a series of `ENABLE_NPKIT*` flags. NPKit predefined flags can be found at `src/include/npkit/npkit_event.h`. In this example,

* `ENABLE_NPKIT` is used to enable NPKit library.

* `ENABLE_NPKIT_EVENT_TIME_SYNC_CPU` is used to synchronize CPU time, and is required if one wants to collect CPU-side events. `ENABLE_NPKIT_EVENT_TIME_SYNC_GPU` is used to synchronize GPU time, and is required for GPU-side events.

* `ENABLE_NPKIT_EVENT_PRIM_LL128_DATA_PROCESS_ENTRY` and `ENABLE_NPKIT_EVENT_PRIM_LL128_DATA_PROCESS_EXIT` are used to collect LL128 data transfer time in GPU.

* `ENABLE_NPKIT_EVENT_NET_SEND_ENTRY ENABLE_NPKIT_EVENT_NET_SEND_EXIT ENABLE_NPKIT_EVENT_NET_RECV_ENTRY ENABLE_NPKIT_EVENT_NET_RECV_EXIT` are used to collect network send/recv time in CPU.

## Usage Example

`src/samples/npkit/test_npkit_events.sh` contains a basic NPKit profiling workflow using nccl-tests. It sets some variables and then calls `run_nccl_tests_with_npkit.sh` to complete the profiling. To get it run, one needs to:

In `test_npkit_events.sh`:
* Make sure `NPKIT_NCCL_TEST_BIN` is correctly set.
* Make sure `NPKIT_NCCL_PROTO` (NCCL_PROTO) and `NPKIT_NCCL_ALGO` (NCCL_ALGO) are correctly set.
* Make sure `NPKIT_FLAGS` is correctly set. `NPKIT_FLAGS` in build section can be a reference.

In `run_nccl_tests_with_npkit.sh`:
* Make sure `hostfile` is filled with correct hostnames separated by new lines. Make sure the nodes can be accessed by ssh silently without password hint.
* Make sure `parellel-ssh` and `parallel-scp` are installed.
* Make sure `nccl_test` function in `run_nccl_tests_with_npkit.sh` makes sense on current platform. Note that currently NPKit only support 1-GPU-1-Process mode.
* Make sure `npkit_src_dir` and `npkit_run_dir` are correct.

Then run

        $ bash test_npkit_events.sh

Results can be found at `${npkit_run_dir}/npkit_post_process/npkit_result.tar.gz`. Decompress this file and one gets `npkit_event_trace.json` viewable by trace viewer.

## Trademarks

This project may contain trademarks or logos for projects, products, or services.
Authorized use of Microsoft trademarks or logos is subject to and must follow [Microsoft's Trademark & Brand Guidelines](https://www.microsoft.com/en-us/legal/intellectualproperty/trademarks/usage/general).
Use of Microsoft trademarks or logos in modified versions of this project must not cause confusion or imply Microsoft sponsorship.
Any use of third-party trademarks or logos are subject to those third-party's policies.
