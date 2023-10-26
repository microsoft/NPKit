## Important Note

We highly recommend using [msccl_samples](https://github.com/microsoft/NPKit/tree/main/msccl_samples) to profile NCCL, because [MSCCL](https://github.com/Azure/msccl) includes all NCCL functions, has NPKit already integrated and is actively maintained by Azure. The patch for NCCL in this folder is not actively maintained.

## Introduction

This folder contains scripts for NPKit sample workflow for NCCL. The sample workflow first builds NCCL with NPKit enabled, then runs nccl-tests to collect NPKit event dump files, and finally generates NPKit trace file.

## Dependencies

[NCCL 2.17.1-1](https://github.com/nvidia/nccl/tree/v2.17.1-1) and [nccl-tests](https://github.com/nvidia/nccl-tests).

## Usage

1) Get NCCL version 2.17.1-1 and apply `npkit-for-nccl-2.17.1-1.diff` to the source repo.

2) Make sure parameters in `npkit_launcher.sh` are valid. Also note that currently NPKit only supports collecting non-overlapped events in GPU, and `NPKIT_FLAGS` should follow this rule.

3) Make sure `nccl_test` function in `npkit_runner.sh` is a valid command to run `nccl-tests` binary. Also note that currently NPKit only supports 1 GPU per process, so `-g 1` mode is required in `nccl-tests` commands.

4) Run command `bash npkit_launcher.sh`.

5) The generated trace file `npkit_event_trace.json` (zipped in `npkit_result.tar.gz`) is in [Google Trace Event Format](https://docs.google.com/document/d/1CvAClvFfyA5R-PhYUmn5OOQtYMH4h6I0nSsKchNAySU/preview) and can be viewed by trace viewers.
