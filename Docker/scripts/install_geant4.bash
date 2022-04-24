#!/bin/bash

pkgname=geant4
pkgver=10.07.p03
pkg_url=https://cern.ch/geant4-data/releases/${pkgname}.${pkgver}.tar.gz
srcdir=$(pwd)/${pkgname}/src/${pkgver}
insdir=$(pwd)/${pkgname}/${pkgver}

[ -d ${srcdir} ] || mkdir -p ${srcdir}

wget --no-check-certificate \
    -P ${srcdir} \
    -c ${pkg_url}

cd ${srcdir}
tar xvf geant4*.tar.gz

[ -d ${srcdir}/build ] || mkdir ${srcdir}/build
cd ${srcdir}/build

cmake \
    -DCMAKE_INSTALL_PREFIX=${insdir} \
    -DGEANT4_INSTALL_DATA=ON \
    -DCMAKE_BUILD_TYPE=Release \
    -DGEANT4_BUILD_MULTITHREADED=ON \
    -DGEANT4_USE_GDML=ON \
    -DGEANT4_USE_G3TOG4=OFF \
    -DGEANT4_USE_QT=OFF \
    -DGEANT4_USE_XM=OFF \
    -DGEANT4_USE_OPENGL_X11=OFF \
    -DGEANT4_USE_INVENTOR=OFF \
    -DGEANT4_USE_RAYTRACER_X11=OFF \
    -DGEANT4_USE_SYSTEM_CLHEP=OFF \
    -DGEANT4_USE_SYSTEM_EXPAT=OFF \
    -DGEANT4_USE_SYSTEM_ZLIB=OFF \
    ../${pkgname}.${pkgver}

G4VERBOSE=1 make -j10
make install
