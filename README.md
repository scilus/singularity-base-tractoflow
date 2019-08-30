# singularity-base-tractoflow
Base container containing dependencies that do not frequently change for the Tractoflow singularity.

Build commands:

sudo docker build . -t "tractoflow:docker"

Dependencies versions:

* FSL: 5.0.9-5~nd16.04+1
* ANTs: v2.3.1
* MRtrix: 3.0_RC3
