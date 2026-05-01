#!/bin/bash
set -e
cd ../..
mkdir -p temp
cd temp
cmake -DCODE_COVERAGE=ON -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX=../temp/install -G "Unix Makefiles" ..
make -j4 all
ctest -T test
ctest -T coverage
cd ../build/Unix
