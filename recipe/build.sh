#!/bin/bash

set -x -e
set -o pipefail

CFLAGS="${CFLAGS} -I${PREFIX}/include -fPIC"
CXXFLAGS="${CXXFLAGS} -fPIC -w -fopenmp"

BOOST_LIBS="boost_python${CONDA_PY}"

# OpenMP runtime: GNU libgomp on Linux, LLVM libomp on macOS.
# On macOS also pass -headerpad_max_install_names so conda-build's
# install_name_tool rewrite step doesn't run out of header space when
# substituting the long _h_env_placehold... prefix into RPATHs.
LD_PLATFORM_EXTRA=""
if [[ "$(uname)" == "Darwin" ]]; then
    OMP_LIB="omp"
    LD_PLATFORM_EXTRA="-Wl,-headerpad_max_install_names"
else
    OMP_LIB="gomp"
fi
PYTHON_LIB_PATH="${PREFIX}/lib"
PYTHON_INC_PATH="${PREFIX}/include/python${PY_VER}"
PYTHON_LIB_NAME="python${PY_VER}"
BUILD_SILO=0

# debug
find ${PREFIX} -iname Python.h
find ${PREFIX} -iname libboost_python*
find ${PREFIX} -iname libpython*

export LD_LIBRARY_PATH=$CONDA_PREFIX/lib:$LD_LIBRARY_PATH

# Source layout changed in 6.x: single tarball (no separate netcdf-cxx4
# folder), so build from ${SRC_DIR} directly rather than ${SRC_DIR}/escript.
cd ${SRC_DIR}

# conda-forge ships umfpack.h under include/suitesparse/, but scons
# findLibWithHeader only handles include/<header> when given a string prefix.
# SCons CLI args are strings, so set the [include, lib] list in the options
# file instead.
cat >> ${SRC_DIR}/scons/templates/anaconda_options.py <<EOF

import os as _os
umfpack_prefix = [_os.path.join('${PREFIX}', 'include', 'suitesparse'),
                  _os.path.join('${PREFIX}', 'lib')]
del _os

# hdf5_libs defaults to the literal string 'DEFAULT' which the build then
# tries to -lDEFAULT. Set the real conda-forge lib names.
hdf5_libs = ['hdf5_cpp', 'hdf5']

# conda-forge ships mumps-seq with a '_seq' suffix and only the four
# precision-variant libs + the mpiseq shim.  escript's default list expects
# system-MUMPS names (mumps_common, dmumps, ... plus lapack/metis/scotch/
# esmumps/gfortran which conda-forge pulls in transitively as SONAMEs).
mumps_seq_libs = ['dmumps_seq', 'zmumps_seq', 'mumps_common_seq', 'pord_seq', 'mpiseq']
EOF

# dependencies.py hard-codes a Windows-style 'Lib/' path when CONDA_PREFIX is
# set, which fails on Linux/macOS. Patch it to use numpy.get_include() instead.
# (Avoid `sed -i` — flag semantics differ between GNU and BSD sed.)
${PREFIX}/bin/python - <<PYEOF
path = "${SRC_DIR}/site_scons/dependencies.py"
import numpy
new = repr(numpy.get_include())
with open(path) as f:
    text = f.read()
text = text.replace("conda_prefix+'/Lib/site-packages/numpy/core/include'", new)
with open(path, "w") as f:
    f.write(text)
PYEOF

scons -j"${CPU_COUNT}" \
    options_file="${SRC_DIR}/scons/templates/anaconda_options.py" \
    build_dir=${BUILD_PREFIX}/escript_build \
    boost_prefix=${PREFIX} \
    boost_libs=${BOOST_LIBS} \
    cxx=${CXX} \
    cppunit_prefix=${PREFIX} \
    hdf5_prefix=${PREFIX} \
    ld_extra="-L${PREFIX}/lib -l${OMP_LIB} ${LD_PLATFORM_EXTRA}" \
    openmp=1 \
    omp_flags="-fopenmp" \
    paso=1 \
    PREFIX=${PREFIX} \
    pythoncmd=${PREFIX}/bin/python \
    pythonlibpath=${PYTHON_LIB_PATH} \
    pythonincpath=${PYTHON_INC_PATH} \
    pythonlibname=${PYTHON_LIB_NAME} \
    silo=${BUILD_SILO} \
    silo_prefix=${PREFIX} \
    trilinos=0 \
    build_trilinos=never \
    trilinos_src=${SRC_DIR} \
    umfpack=1 \
    mumps_seq=1 \
    mumps_seq_prefix=${PREFIX} \
    build_full || cat config.log

ln -s ${PREFIX}/lib/buildvars ${PREFIX}/lib/buildvars.in
cp -R ${PREFIX}/esys ${SP_DIR}/esys
