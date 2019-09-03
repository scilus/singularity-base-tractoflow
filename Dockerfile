FROM ubuntu:xenial

ENV ITK_GLOBAL_DEFAULT_NUMBER_OF_THREADS=8
ENV OPENBLAS_NUM_THREADS=1
ENV DEBIAN_FRONTEND=noninteractive

RUN sed -i 's/main/main restricted universe/g' /etc/apt/sources.list
RUN apt-get update

RUN apt-get -y install locales
ENV LC_CTYPE="en_US.UTF-8"
ENV LC_ALL="en_US.UTF-8"
ENV LANG="en_US.UTF-8"
ENV LANGUAGE="en_US.UTF-8"
RUN locale-gen "en_US.UTF-8"
RUN dpkg-reconfigure locales

RUN apt-get -y install wget
RUN wget -O- http://neuro.debian.net/lists/xenial.us-ca.full | tee /etc/apt/sources.list.d/neurodebian.sources.list
RUN apt-key adv --recv-keys --keyserver pool.sks-keyservers.net 2649A5A9 || { wget -q -O- http://neuro.debian.net/_static/neuro.debian.net.asc | apt-key add -; }
RUN apt-get update
RUN apt-get -y install git
RUN apt-get -y install build-essential
RUN apt-get -y install zlib1g-dev
RUN apt-get -y install g++
RUN apt-get -y install gcc

WORKDIR /
RUN wget https://github.com/Kitware/CMake/releases/download/v3.13.2/cmake-3.13.2.tar.gz
RUN tar -xvzf cmake-3.13.2.tar.gz
RUN rm -rf cmake-3.13.2.tar.gz
WORKDIR /cmake-3.13.2
RUN ./bootstrap
RUN make -j 8
RUN make install
WORKDIR /

RUN apt-get -y install libeigen3-dev
RUN apt-get -y install libqt4-opengl-dev
RUN apt-get -y install libgl1-mesa-dev
RUN apt-get -y install libfftw3-dev
RUN apt-get -y install libtiff5-dev
RUN apt-get -y install clang
RUN apt-get -y install libblas-dev liblapack-dev

RUN apt-get -y install fsl-5.0=5.0.9-5~nd16.04+1
RUN apt-get -y install fsl-5.0-eddy-nonfree=5.0.9-1~nd16.04+1
ENV FSLDIR=/usr/share/fsl/5.0
ENV PATH=${FSLDIR}/bin:$PATH
ENV LD_LIBRARY_PATH=/usr/lib/fsl/5.0:/usr/share/fsl/5.0/bin
ENV FSLBROWSER=/etc/alternatives/x-www-browser
ENV FSLCLUSTER_MAILOPTS=n
ENV FSLLOCKDIR=
ENV FSLMACHINELIST=
ENV FSLMULTIFILEQUIT=TRUE
ENV FSLOUTPUTTYPE=NIFTI_GZ
ENV FSLREMOTECALL=
ENV FSLTCLSH=/usr/bin/tclsh
ENV FSLWISH=/usr/bin/wish
ENV POSSUMDIR=/usr/share/fsl/5.0

RUN wget https://fsl.fmrib.ox.ac.uk/fsldownloads/patches/eddy-patch-fsl-5.0.11/centos6/eddy_openmp
RUN chmod +x eddy_openmp
RUN mv eddy_openmp /usr/share/fsl/5.0/bin/eddy_openmp

RUN wget https://developer.download.nvidia.com/compute/cuda/repos/ubuntu1604/x86_64/cuda-repo-ubuntu1604_8.0.61-1_amd64.deb
RUN dpkg -i cuda-repo-ubuntu1604_8.0.61-1_amd64.deb
RUN apt-get update
RUN DEBIAN_FRONTEND=noninteractive apt-get -y install cuda-runtime-8-0

RUN wget https://fsl.fmrib.ox.ac.uk/fsldownloads/patches/eddy-patch-fsl-5.0.11/centos6/eddy_cuda8.0
RUN chmod +x eddy_cuda8.0
RUN mv eddy_cuda8.0 /usr/share/fsl/5.0/bin/eddy_cuda

WORKDIR /
RUN mkdir ants_build
RUN git clone https://github.com/ANTsX/ANTs.git
WORKDIR /ANTs
RUN git fetch --tags
RUN git checkout tags/v2.3.1 -b v2.3.1
WORKDIR /ants_build
RUN cmake ../ANTs
RUN make -j 8
RUN cp ../ANTs/Scripts/*.sh bin/
ENV ANTSPATH=/ants_build/bin
ENV PATH=$PATH:$ANTSPATH

WORKDIR /
RUN apt-get -y install unzip
RUN git clone https://github.com/MRtrix3/mrtrix3.git
WORKDIR /mrtrix3
RUN git fetch --tags
RUN git checkout tags/3.0_RC3 -b 3.0_RC3
RUN ./configure
RUN NUMBER_OF_PROCESSORS=8 ./build
ENV PATH=/mrtrix3/bin:$PATH
