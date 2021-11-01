# NPKit

A profiling tool of collective communication.

## Introduction

NPKit (NCCL Profiling Kit) is a profiling tool of collective communication, implementing all-reduce, all-gather, reduce, broadcast, reduce-scatter, as well as any send/receive based communication pattern. NPKit supports an arbitrary number of GPUs installed in a single node or across multiple nodes, and can be used in either single- or multi-process (e.g., MPI) applications.

## Build

NPKit needs to be built with NCCL/RCCL. Please get NCCL/RCCL source code, apply the patch files and build.

