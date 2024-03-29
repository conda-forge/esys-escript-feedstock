#!/bin/bash

set -x -e
set -o pipefail

CFLAGS="${CFLAGS} -I${PREFIX}/include -fPIC"
CXXFLAGS="${CXXFLAGS} -fPIC -w -fopenmp"

# INSTALL_PATH=${PREFIX}
# TRILINOS_BUILD=${SRC_DIR}/trilinos

# cmake \
#   -D CMAKE_INSTALL_PREFIX=$INSTALL_PATH \
#   -D CMAKE_BUILD_TYPE=RELEASE \
#   -D CMAKE_CXX_FLAGS=" " \
#   -D CMAKE_C_FLAGS=" " \
#   -D Trilinos_ENABLE_CXX11=ON \
#   -D Trilinos_ENABLE_Fortran=OFF \
#   -D BUILD_SHARED_LIBS=ON \
#   -D TPL_ENABLE_BLAS=ON \
#   -D TPL_ENABLE_Boost=OFF \
#   -D TPL_ENABLE_Cholmod=ON \
#   -D TPL_ENABLE_LAPACK=ON \
#   -D TPL_ENABLE_METIS=ON \
#   -D TPL_ENABLE_SuperLU=OFF \
#   -D TPL_ENABLE_UMFPACK=ON \
#   -D Trilinos_ENABLE_Amesos=ON \
#   -D Trilinos_ENABLE_Amesos2=ON \
#   -D Trilinos_ENABLE_AztecOO=ON \
#   -D Trilinos_ENABLE_Belos=ON \
#   -D Trilinos_ENABLE_Ifpack=ON \
#   -D Trilinos_ENABLE_Ifpack2=ON \
#   -D Trilinos_ENABLE_Kokkos=ON \
#   -D Trilinos_ENABLE_Komplex=ON \
#   -D Trilinos_ENABLE_ML=ON \
#   -D Trilinos_ENABLE_MueLu=ON \
#   -D Trilinos_ENABLE_Teuchos=ON \
#   -D Trilinos_ENABLE_Tpetra=ON \
#   -D Trilinos_ENABLE_ALL_OPTIONAL_PACKAGES=ON \
#   -D Trilinos_ENABLE_OpenMP=ON \
#   -D Trilinos_ENABLE_MPI=OFF \
#   -D Trilinos_ENABLE_EXPLICIT_INSTANTIATION=ON \
#   -D Kokkos_ENABLE_AGGRESSIVE_VECTORIZATION=ON \
#   -D Amesos2_ENABLE_Basker=ON \
#   -D Tpetra_INST_SERIAL:BOOL=ON \
#   -D Trilinos_ENABLE_TESTS=OFF \
#   -D Tpetra_INST_INT_INT=ON \
#   -D Teuchos_ENABLE_COMPLEX=ON \
#   -D Trilinos_ENABLE_COMPLEX_DOUBLE=ON \
#   $TRILINOS_BUILD

# make -j"${CPU_COUNT}" install


BOOST_LIBS="boost_python${CONDA_PY}"
PYTHON_LIB_PATH="${PREFIX}/lib"
PYTHON_INC_PATH="${PREFIX}/include/python${PY_VER}"
PYTHON_LIB_NAME="python${PY_VER}"
BUILD_SILO=0

# debug
find ${PREFIX} -iname Python.h
find ${PREFIX} -iname libboost_python*
find ${PREFIX} -iname libpython*
find ${PREFIX} -iname libmpi_cxx*

export LD_LIBRARY_PATH=$CONDA_PREFIX/lib:$LD_LIBRARY_PATH

cd ${SRC_DIR}/escript
scons -j"${CPU_COUNT}" \
    options_file="${SRC_DIR}/escript/scons/templates/anaconda_python3_options.py" \
    build_dir=${BUILD_PREFIX}/escript_build \
    boost_prefix=${PREFIX} \
    boost_libs=${BOOST_LIBS} \
    cxx=${CXX} \
    cxx_extra="-w -fPIC -fdiagnostics-color=always -std=c++17 --verbose" \
    cppunit_prefix=${PREFIX} \
    ld_extra="-L${PREFIX}/lib -lgomp" \
    openmp=0 \
    omp_flags="-fopenmp" \
    paso=1 \
    prefix=${PREFIX} \
    pythoncmd=${PREFIX}/bin/python \
    pythonlibpath=${PYTHON_LIB_PATH} \
    pythonincpath=${PYTHON_INC_PATH} \
    pythonlibname=${PYTHON_LIB_NAME} \
    silo=${BUILD_SILO} \
    silo_prefix=${PREFIX} \
    trilinos=0 \
    umfpack=0 \
    umfpack_prefix=${PREFIX} \
    build_full || cat config.log

cp -R ${SRC_DIR}/escript/LICENSE ${SRC_DIR}/LICENSE
ln -s ${PREFIX}/lib/buildvars ${PREFIX}/lib/buildvars.in
cp -R ${PREFIX}/esys ${SP_DIR}/esys
cp -R ${BUILD_PREFIX}/escript_build/scripts/release_sanity.py /tmp/release_sanity.py
