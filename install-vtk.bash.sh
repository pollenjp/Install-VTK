#!/bin/bash -eux

# [bash - What's a concise way to check that environment variables are set in a Unix shell script? - Stack Overflow](https://stackoverflow.com/a/307735/9316234)
#VTK_VERSION=1.70.0
: "${VTK_VERSION:?Need to be set. (ex: '$ VTK_VERSION=8.2.0 ./xxx.sh')}"
# 'shared' or 'static'
: "${VTK_LIBS:?Need to be set. 'static' or 'shared' (ex: '$ VTK_LIBS=shared ./xxx.sh')}"

if [ ${VTK_LIBS} == "static" ]; then
    BUILD_SHARED_LIBS=OFF
elif [ ${VTK_LIBS} == "shared" ]; then
    BUILD_SHARED_LIBS=ON
else
    printf "\e[101m %s \e[0m \n" "Variable VTK_LIBS should be 'static' or 'shared'."
    exit 1
fi

VTK_DIR=${HOME}/.vtk
CMAKE_INSTALL_PREFIX=${VTK_DIR}/install/vtk-${VTK_VERSION}/${VTK_LIBS}
if [ -d "${CMAKE_INSTALL_PREFIX}" ]; then
  rm -rf ${CMAKE_INSTALL_PREFIX}
fi
# current working directory
CWD=$(pwd)


#=======================================
# if a directory or a symbolic link does not exist
if [ ! -d ${VTK_DIR} ] && [ ! -L ${VTK_DIR} ]; then
  mkdir ${VTK_DIR}
fi

#=======================================
# clone vtk
cd ${VTK_DIR}
if [ ! -d "${VTK_DIR}/vtk" ]; then
  git clone https://gitlab.kitware.com/vtk/vtk.git
fi

cd "${VTK_DIR}/vtk"
git checkout master
git fetch
git pull --all
git checkout "v${VTK_VERSION}"
cd ${VTK_DIR}
 
#=======================================
# build
directory1=${VTK_DIR}/vtk/build
if [ -d "${directory1}" ]; then
  rm -rf ${directory1}
fi
mkdir ${directory1}
cd ${directory1}
echo ${directory1}

#=======================================
cmake \
    -D CMAKE_BUILD_TYPE:STRING=Release \
    -D BUILD_SHARED_LIBS=${BUILD_SHARED_LIBS} \
    -D CMAKE_INSTALL_PREFIX=${CMAKE_INSTALL_PREFIX} \
    ..

if [ -d "${CMAKE_INSTALL_PREFIX}" ]; then
  rm -rf ${CMAKE_INSTALL_PREFIX}
fi
make -j4
make install

#===============================================================================
# Back to working directory
cd ${CWD}