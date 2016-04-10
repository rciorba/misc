#!/bin/bash
mkdir -p build_dir
cd build_dir
git clone --depth 1 git://git.sv.gnu.org/emacs.git 
cd emacs
./autogen.sh
PREFIX=/home/rciorba/software/emacs
./configure  --prefix=$PREFIX
mkdir $PREFIX
make bootstrap
make install