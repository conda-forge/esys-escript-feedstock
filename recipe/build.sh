#!/bin/bash

set -x -e
set -o pipefail

CFLAGS="${CFLAGS} -I${PREFIX}/include -fPIC"
CXXFLAGS="${CXXFLAGS} -fPIC -w -fopenmp"

BOOST_LIBS="boost_python${CONDA_PY}"
PYTHON_LIB_PATH="${PREFIX}/lib"
PYTHON_INC_PATH="${PREFIX}/include/python${PY_VER}"
PYTHON_LIB_NAME="python${PY_VER}"
BUILD_SILO=0

# export LD_LIBRARY_PATH=${PREFIX}/lib

cd ${SRC_DIR}/escript
scons -j"${CPU_COUNT}" \
    options_file="${SRC_DIR}/escript/scons/templates/buster_py3_options.py" \
    prefix=${PREFIX} \
    build_dir=${BUILD_PREFIX} \
    boost_prefix=${PREFIX} \
    boost_libs="boost_python39" \
    cxx=${CXX} \
    cxx_extra="-w -fPIC" \
    ld_extra="-L${PREFIX}/lib -lgomp" \
    cppunit_prefix=${PREFIX} \
    openmp=1 \
    omp_flags="-fopenmp" \
    pythoncmd=${PREFIX}/bin/python \
    pythonlibpath="${PREFIX}/lib" \
    pythonincpath="${PREFIX}/include/python3.9" \
    pythonlibname="python3.9" \
    paso=1 \
    silo=${BUILD_SILO} \
    silo_prefix=${PREFIX} \
    trilinos=0 \
    umfpack=1 \
    umfpack_prefix="${PREFIX}" \
    netcdf=no \
    werror=0 \
    verbose=0 \
    compressed_files=0 \
    build_full || cat config.log

cp -R ${SRC_DIR}/escript/LICENSE ${SRC_DIR}/LICENSE
cp -R ${PREFIX}/esys ${SP_DIR}/esys
cp -R ${BUILD_PREFIX}/scripts/release_sanity.py /tmp/release_sanity.py
