FROM ubuntu:bionic

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

RUN apt-get -y install wget gnupg
RUN wget -O- http://neuro.debian.net/lists/bionic.us-ca.full | tee /etc/apt/sources.list.d/neurodebian.sources.list
RUN apt-key adv --recv-keys --keyserver hkp://pool.sks-keyservers.net:80 0xA5D32F012649A5A9 || { wget -q -O- http://neuro.debian.net/_static/neuro.debian.net.asc | apt-key add -; }
RUN apt-get update
RUN apt-get -y install git
RUN apt-get -y install build-essential
RUN apt-get -y install zlib1g-dev
RUN apt-get -y install g++
RUN apt-get -y install gcc
RUN apt-get -y install libssl-dev

WORKDIR /
ENV CMAKE_VERSION="3.19.6"
RUN wget https://github.com/Kitware/CMake/releases/download/v${CMAKE_VERSION}/cmake-${CMAKE_VERSION}.tar.gz
RUN tar -xvzf cmake-${CMAKE_VERSION}.tar.gz
RUN rm -rf cmake-${CMAKE_VERSION}.tar.gz
WORKDIR /cmake-${CMAKE_VERSION}
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

RUN apt-get -y install fsl-5.0=5.0.9-5~nd18.04+1
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

WORKDIR /
RUN wget https://developer.nvidia.com/compute/cuda/8.0/Prod2/local_installers/cuda_8.0.61_375.26_linux-run --quiet
RUN chmod +x cuda_8.0.61_375.26_linux-run
RUN ./cuda_8.0.61_375.26_linux-run --override --silent

RUN wget https://fsl.fmrib.ox.ac.uk/fsldownloads/patches/eddy-patch-fsl-5.0.11/centos6/eddy_cuda8.0
RUN chmod +x eddy_cuda8.0
RUN mv eddy_cuda8.0 /usr/share/fsl/5.0/bin/eddy_cuda

ENV ANTS_VERSION="2.3.1"
RUN mkdir ants_build
RUN git clone https://github.com/ANTsX/ANTs.git
WORKDIR /ANTs
RUN git fetch --tags
RUN git checkout tags/v${ANTS_VERSION} -b v${ANTS_VERSION}
WORKDIR /ants_build
RUN cmake ../ANTs
RUN make -j 6
RUN cp ../ANTs/Scripts/*.sh bin/
ENV ANTSPATH=/ants_build/bin
ENV PATH=$PATH:$ANTSPATH

WORKDIR /
ENV MRTRIX_VERSION="3.0_RC3"
RUN apt-get -y install unzip
RUN git clone https://github.com/MRtrix3/mrtrix3.git
WORKDIR /mrtrix3
RUN git fetch --tags
RUN git checkout tags/${MRTRIX_VERSION} -b ${MRTRIX_VERSION}
RUN ./configure
RUN NUMBER_OF_PROCESSORS=6 ./build
ENV PATH=/mrtrix3/bin:$PATH
