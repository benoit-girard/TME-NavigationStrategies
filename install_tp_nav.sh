#!/bin/sh

# Alex Coninx
# ISIR - Sorbonne Universite / CNRS
# 7/10/2019

# Dependecies : boost, sdl, C++11 compatible compiler, python3, pip3, python2.7,
# git
# This will create a venv. To use the dependencies you should activate it:
# For bash 'source venv/bin/activate'
# For fish '. ./venv/bin/activate.fish'

set -o errexit
set -o nounset
set -o pipefail

BASE_DIR="${PWD}"

# Create venv
python3 -m venv venv
source venv/bin/activate

# Create dir
mkdir -p "${BASE_DIR}/src"

# Install numpy
pip install numpy==1.17.2

# 1) Install pybind11
echo
echo "====================================="
echo "===== (1/4) Installing pybind11 ====="
echo "====================================="
echo
cd "${BASE_DIR}/src"
git clone https://github.com/pybind/pybind11.git
cd pybind11
# Install the pybind11 python module
pip3 install .
# Where we can find pybind11 (especially its includes)
PYBIND11_DIR="${BASE_DIR}/src/pybind11"
 
# 2) Install and patch fastsim
echo
echo "===================================================="
echo "===== (2/4) Patching and installing libfastsim ====="
echo "===================================================="
echo
cd "${BASE_DIR}/src"
git clone https://github.com/jbmouret/libfastsim.git
# We need to clone the pyfastsim repository now to get the patch
git clone https://github.com/alexendy/pyfastsim.git
cd libfastsim
# Patch libfastsim
patch -p1 < ../pyfastsim/fastsim-boost2std-fixdisplay.patch
# Build and install
python2.7 ./waf configure --prefix=./install
python2.7 ./waf build
python2.7 ./waf install
# Where we installed fastsim
FASTSIM_DIR="${BASE_DIR}/src/libfastsim/install"

# 3) Install pyfastsim
echo
echo "======================================"
echo "===== (3/4) Installing pyfastsim ====="
echo "======================================"
echo
cd "${BASE_DIR}/src/pyfastsim"
CPPFLAGS="-I\"${PYBIND11_DIR}/include\" -I\"${FASTSIM_DIR}/include\"" LDFLAGS="-L\"${FASTSIM_DIR}/lib\"" pip3 install .

# 4) install the exercises
echo
echo "=================================================="
echo "===== (4/4) Getting the navigation exercises ====="
echo "=================================================="
echo
cd "${BASE_DIR}/src"
git clone https://github.com/benoit-girard/TME-NavigationStrategies.git
cd TME-NavigationStrategies
echo
echo
echo "********************************************************************************"
echo "Navigation exercises are installed in: ${PWD}"
echo "Go there and test the installation with, for example : % python3 wallFollower.py"
echo "********************************************************************************"
