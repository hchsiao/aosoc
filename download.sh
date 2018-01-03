#!/bin/bash

ROOT=`pwd`

git clone https://github.com/riscv/riscv-fesvr.git
git clone https://github.com/hchsiao/riscv-isa-sim.git
git clone https://github.com/hchsiao/riscv-openocd.git
git clone https://github.com/hchsiao/zero-riscy.git
git clone https://github.com/hchsiao/openocd_jtag_dpi.git
git clone http://vlsigit.ee.ncku.edu.tw/hchsiao/zero-buggy.git

cd $ROOT/riscv-fesvr
mkdir -p build
./configure --prefix=`pwd`/build
make install

cd $ROOT/riscv-isa-sim
mkdir -p build
./configure --prefix=`pwd`/build --with-fesvr=`pwd`/../riscv-fesvr/build
make install

cd $ROOT/riscv-openocd
mkdir -p build
./bootstrap
./configure --prefix=`pwd`/build --enable-remote-bitbang --enable-jtag_vpi
make
make install

cd $ROOT
