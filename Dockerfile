FROM ubuntu:16.04
MAINTAINER Felipe H. da Jornada <jornada@berkeley.edu>

RUN apt-get update && apt-get -y install \
    gfortran g++ libopenmpi-dev openmpi-bin libhdf5-openmpi-dev \
    python-numpy make curl && apt-get clean


# Build and install the following libraries with OpenMP support:
# 1. OpenBLAS
# 2. FFTW
# 3. LAPACK
# 4. ScaLAPCK

WORKDIR /root

ENV OB_VER=0.2.19
ENV BLAS=OpenBLAS-${OB_VER}
ENV OB_FLAGS="CC=gcc FC=gfortran USE_OPENMP=1 NO_SHARED=1 NO_CBLAS=1 NO_LAPACK=1 MAKE_NB_JOBS=8"
RUN mkdir ${BLAS}
RUN /bin/bash -l -c '\
    curl -L "http://github.com/xianyi/OpenBLAS/archive/v${OB_VER}.tar.gz" | \
    tar xz && cd ${BLAS} && \
    make ${OB_FLAGS} && make ${OB_FLAGS} PREFIX=/opt/${BLAS} install && \ 
    cd ../ && rm -rf ${BLAS}'

ENV FFTW=fftw-3.3.5
RUN mkdir ${FFTW}
RUN /bin/bash -l -c '\
    curl "ftp://ftp.fftw.org/pub/fftw/${FFTW}.tar.gz" | \
    tar xz && cd ${FFTW} && \
    ./configure --enable-openmp --prefix=/opt/${FFTW} F77=gfortran F90=gfortran && \
    make -j 8 && make install && \
    cd ../ && rm -rf ${FFTW}'

ENV LAPACK=lapack-3.6.1
RUN mkdir ${LAPACK}
COPY make.inc ./${LAPACK}/
RUN /bin/bash -l -c '\
    curl "http://www.netlib.org/lapack/${LAPACK}.tgz" | \
    tar xz && cd ${LAPACK} && \
    make lapacklib -j 8 && cp liblapack.a /lib64 && \
    cd ../ && rm -rf ${LAPACK}'

ENV SCALAPACK=scalapack-2.0.2
RUN mkdir ${SCALAPACK}
COPY SLmake.inc ./${SCALAPACK}/
RUN /bin/bash -l -c '\
    curl "http://www.netlib.org/scalapack/${SCALAPACK}.tgz" | \
    tar xz && cd ${SCALAPACK} && \
    make lib && cp libscalapack.a /lib64 && \
    cd ../ && rm -rf ${SCALAPACK}'


# Install su-exec, to fix permission on the entrypoint.
# Adapted from: https://denibertovic.com/posts/handling-permissions-with-docker-volumes/
RUN /bin/bash -l -c '\
    curl -L "https://github.com/javabean/su-exec/archive/v0.2.tar.gz" | \
    tar xz && cd su-exec-0.2 && make && mv su-exec /usr/local/bin && \
    cd ../ && rm -rf su-exec-0.2'


# Remove stack limit, otherwise OpenMP crashes.
# Add bgw user, home dir, and scratch
ENV TMPDIR=/scratch
RUN echo '* - stack unlimited' > /etc/security/limits.d/90-core.conf
RUN mkdir ${TMPDIR}


# Download and compile BerkeleyGW.
ENV BGW_URL="https://berkeley.box.com/shared/static/829s6ha4popx1g4cslpklzh5znf2v6la.gz"
ENV BGW_DIR=/opt/BerkeleyGW-1.2.0
RUN mkdir ${BGW_DIR}
COPY arch.mk ${BGW_DIR}
RUN /bin/bash -l -c '\
    cd /opt && curl -L "${BGW_URL}" | tar xz && cd "${BGW_DIR}" && \
    make all-flavors -j 8 && make clean'


# Setup path and the directory where we'll run the calculation
# Adapted from: https://denibertovic.com/posts/handling-permissions-with-docker-volumes/
ENV PATH="${BGW_DIR}/bin:${PATH}"
WORKDIR ${TMPDIR}
COPY entrypoint.sh /usr/local/bin/entrypoint.sh
ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
CMD ["/bin/bash"]
