#!/bin/bash

pkgname=root
pkgver=6.24.00
pkg_url=https://root.cern/download/root_v${pkgver}.source.tar.gz
srcdir=$(pwd)/${pkgname}/src/${pkgver}
insdir=$(pwd)/${pkgname}/${pkgver}

[ -d ${srcdir} ] || mkdir -p ${srcdir}

wget \
    -P ${srcdir} \
    -c ${pkg_url}

cd ${srcdir}
tar xvf root*source.tar.gz

[ -d ${srcdir}/build ] || mkdir ${srcdir}/build
cd ${srcdir}/build

SYSTEM_PYTHON3=$(which python3)

cmake \
    -DCMAKE_INSTALL_PREFIX=${insdir} \
    -Dgnuinstall=ON \
    -Droofit=OFF \
    -Dpython3=ON -DPYTHON_EXECUTABLE=${SYSTEM_PYTHON3} \
    ../${pkgname}-${pkgver}

make -j4
make install && rm -rf ${srcdir}

# export ROOTSYS=${insdir}
# export PATH=$PATH:$ROOTSYS/bin
# export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:$ROOTSYS/lib/root