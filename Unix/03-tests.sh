#!/bin/bash
set -e
cd ../..
cd temp
ctest -V || true
cd ../build/Unix
