## Introduction

This file describes for NPKit sample workflow for [MSCCL++](https://github.com/microsoft/mscclpp). The sample workflow first builds MSCCL++ with NPKit enabled, then runs MSCCL++ executor test to collect NPKit event dump files, and finally generates NPKit trace file.

## Dependencies

[MSCCL++](https://github.com/microsoft/mscclpp) (with NPKit integrated).

## Usage

1) Build MSCCL++ with NPKit enabled.

```
$ git clone https://github.com/microsoft/mscclpp && cd mscclpp
$ mkdir build && cd build
$ cmake -DCMAKE_BUILD_TYPE=Release -DBUILD_LOCAL_GPU_TARGET_ONLY=ON -DNPKIT_FLAGS="-DENABLE_NPKIT -DENABLE_NPKIT_EVENT_TIME_SYNC_CPU -DENABLE_NPKIT_EVENT_TIME_SYNC_GPU -DENABLE_NPKIT_EVENT_EXECUTOR_OP_BASE_ENTRY -DENABLE_NPKIT_EVENT_EXECUTOR_OP_BASE_EXIT -DENABLE_NPKIT_EVENT_EXECUTOR_INIT_ENTRY -DENABLE_NPKIT_EVENT_EXECUTOR_INIT_EXIT" .. && make -j
```

2) Create a directory to store NPKit dump files and trace files.

```
$ mkdir /path/to/npkit_dump
$ mkdir /path/to/npkit_trace
```

3) Run MSCCL++ executor test with NPKIT_DUMP_DIR specifid.

```
$ mpirun -tag-output -np 2 -x MSCCLPP_DEBUG=WARN -x MSCCLPP_DEBUG_SUBSYS=ALL -x NPKIT_DUMP_DIR=/path/to/npkit_dump -x LD_PRELOAD=/path/to/mscclpp/build/libmscclpp.so:$LD_PRELOAD /path/to/mscclpp/build/test/executor_test 1024 allreduce_pairs /path/to/mscclpp/test/execution-files/allreduce_packet.json 1024 10 1 LL8
```

3) Run NPKit trace parsing script to generate trace file.

```
$ python3 /path/to/mscclpp/tools/npkit/npkit_trace_generator.py --npkit_dump_dir=/path/to/npkit_dump --npkit_event_header_path=/path/to/mscclpp/include/mscclpp/npkit/npkit_event.hpp --output_dir=/path/to/npkit_trace
```

4) The generated trace file `npkit_event_trace.json` is in [Google Trace Event Format](https://docs.google.com/document/d/1CvAClvFfyA5R-PhYUmn5OOQtYMH4h6I0nSsKchNAySU/preview) and can be viewed by trace viewers.
