#!/bin/bash
set -e  # Exit on error

export CC="ccache gcc"
export CXX="ccache g++"

rm -rf build
mkdir build && cd build

conan install .. --build=missing

cmake .. \
  -DCMAKE_BUILD_TYPE=Release \
  -DPython_EXECUTABLE=$(which python) \
  -DPython_INCLUDE_DIRS=$(python -c "from sysconfig import get_paths as gp; print(gp()['include'])") \
  -DPython_LIBRARIES=$(python -c "import sysconfig; print(sysconfig.get_config_var('LIBDIR'))")/libpython$(python -c "import sys; print(f'{sys.version_info.major}.{sys.version_info.minor}')").so \
  -DMUMPS_DIR=/path/to/mumps/build \
  -DSCALAPACK_LIBRARIES="" \
  -DCMAKE_LIBRARY_PATH=/usr/lib \
  -DLAPACK_LIBRARIES="/usr/lib/liblapack.so;/usr/lib/libblas.so"

make -j$(nproc)

make OpenSeesPy -j$(nproc)

cp lib/OpenSeesPy.so lib/opensees.so
