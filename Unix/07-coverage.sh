#!/bin/bash
set -e
cd ../..
mkdir -p temp
cd temp
cmake -DCODE_COVERAGE=ON -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX=../temp/install -G "Unix Makefiles" ..
make -j4 all
ctest -T test
ctest -T coverage

# Create code coverage report
mkdir -p coverage
cd coverage
gcovr --root ../.. --html-details coverage.html --filter '../../source/' --filter '../../include/'
open ./coverage.html
cd ..

cd ../build/Unix
