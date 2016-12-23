# arch.mk for BerkeleyGW codes
#
# Felipe H. da Jornada

COMPFLAG  = -DGNU
PARAFLAG  = -DMPI -DOMP
MATHFLAG  = -DUSESCALAPACK -DUNPACKED -DUSEFFTW3 -DHDF5
# Only uncomment DEBUGFLAG if you need to develop/debug BerkeleyGW.
# The output will be much more verbose, and the code will slow down by ~20%.
#DEBUGFLAG = -DDEBUG -DVERBOSE

FCPP    = cpp -C -nostdinc
F90free = mpif90 -ffree-form -ffree-line-length-none -fopenmp
LINK    = mpif90 -fopenmp
FOPTS   = -O3
FNOOPTS = $(FOPTS)
MOD_OPT = -J
INCFLAG = -I

CC_COMP = mpicxx -O3 -pedantic-errors -std=c++0x -fopenmp
C_COMP  = mpicc -O3 -pedantic-errors -std=c99 -fopenmp
C_LINK  = mpicxx -fopenmp
C_OPTS  = -O3
C_DEBUGFLAG =

REMOVE  = /bin/rm -f

# Math Libraries
#
FFTWLIB      = /opt/$(FFTW)/lib/libfftw3_omp.a /opt/$(FFTW)/lib/libfftw3.a
FFTWINCLUDE  = /opt/$(FFTW)/include
LAPACKLIB    = /lib64/liblapack.a /opt/$(BLAS)/lib/libopenblas.a
SCALAPACKLIB = /lib64/libscalapack.a $(LAPACKLIB)
HDF5LIB      = -L/usr/lib/x86_64-linux-gnu/hdf5/openmpi -lhdf5hl_fortran -lhdf5_hl -lhdf5_fortran -lhdf5 -lz
HDF5INCLUDE  = /usr/include/hdf5/openmpi
