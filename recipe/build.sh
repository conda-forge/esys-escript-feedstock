#!/bin/bash

set -x -e
set -o pipefail

CFLAGS="${CFLAGS} -I${PREFIX}/include -fPIC"
CXXFLAGS="${CXXFLAGS} -fPIC -w -fopenmp"

if [ ${CONDA_PY} -eq 38 ]
then
    BOOST_LIBS="boost_python${CONDA_PY}"
    PYTHON_LIB_PATH="${PREFIX}/lib"
    PYTHON_INC_PATH="${PREFIX}/include/python${PY_VER}"
    PYTHON_LIB_NAME="python${PY_VER}"
    BUILD_SILO=0
else
    DEFAULT_HDF5_INCDIR=$PREFIX/include
    DEFAULT_HDF5_LIBDIR=$PREFIX/lib
    # cd ${SRC_DIR}/silo
    # ./configure --prefix=${PREFIX} \
    #         --with-hdf5=${PREFIX}/include,${PREFIX}/lib \
    #         --with-zlib=$PREFIX/include,$PREFIX/lib
    # make -j"${CPU_COUNT}"
    # make -j"${CPU_COUNT}" install
    BOOST_LIBS="boost_python${CONDA_PY}"
    PYTHON_LIB_PATH="${PREFIX}/lib"
    PYTHON_INC_PATH="${PREFIX}/include/python${PY_VER}m"
    PYTHON_LIB_NAME="python${PY_VER}m"
    BUILD_SILO=0
fi

cd ${SRC_DIR}/escript
if [ ${PY3K} -eq 1 ]
then
    scons -j"${CPU_COUNT}" \
        options_file="${SRC_DIR}/escript/scons/templates/anaconda_python3_options.py" \
        build_dir=${BUILD_PREFIX}/escript_build \
        boost_prefix=${PREFIX} \
        boost_libs=${BOOST_LIBS} \
        cxx=${CXX} \
        cxx_extra="-w -fPIC" \
        cppunit_prefix=${PREFIX} \
        ld_extra="-L${PREFIX}/lib -lgomp" \
        omp_flags="-fopenmp" \
        prefix=${PREFIX} \
        pythoncmd=${PREFIX}/bin/python \
        pythonlibpath=${PYTHON_LIB_PATH} \
        pythonincpath=${PYTHON_INC_PATH} \
        pythonlibname=${PYTHON_LIB_NAME} \
        silo=${BUILD_SILO} \
        silo_prefix=${PREFIX} \
        umfpack_prefix=${PREFIX} \
        build_full || cat config.log
else
    scons -j"${CPU_COUNT}" \
        options_file="${SRC_DIR}/escript/scons/templates/buster_py2_options.py" \
        prefix=${PREFIX} \
        build_dir=${BUILD_PREFIX}/escript_build \
        boost_prefix=${PREFIX} \
        boost_libs="boost_python27" \
        cxx=${CXX} \
        cxx_extra="-w -fPIC" \
        ld_extra="-L${PREFIX}/lib -lgomp" \
        cppunit_prefix=${PREFIX} \
        openmp=1 \
        omp_flags="-fopenmp" \
        pythoncmd=${PREFIX}/bin/python \
        pythonlibpath="${PREFIX}/lib" \
        pythonincpath="${PREFIX}/include/python2.7" \
        pythonlibname="python2.7" \
        paso=1 \
        silo=${BUILD_SILO} \
        silo_prefix=${PREFIX} \
        trilinos=0 \
        umfpack=0 \
        umfpack_prefix="${PREFIX}" \
        netcdf=no \
        werror=0 \
        verbose=0 \
        compressed_files=0 \
        build_full || cat config.log
fi

cp -R ${SRC_DIR}/escript/LICENSE ${SRC_DIR}/LICENSE
cp -R ${PREFIX}/esys ${SP_DIR}/esys
cp -R ${BUILD_PREFIX}/escript_build/scripts/release_sanity.py /tmp/release_sanity.py
