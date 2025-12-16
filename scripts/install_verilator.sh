#!/bin/bash

SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
ROOT_DIR=$(dirname "$SCRIPT_DIR")

echo -e "\n[INFO]: Checking dependencies"
DEPENDENCIES=("git" "make" "autoconf" "g++" "flex" "bison")
for item in "${DEPENDENCIES[@]}"; do
  if command -v $item &> /dev/null; then
    printf "  > %8s is INSTALLED\n" "$item"
  else 
    printf "  > %8s is NOT INSTALLED\n" "$item"
    exit 1
  fi
done
echo -e "[INFO]: All dependencies found\n"

if [ `uname -p` = "x86_64" ]; then
  echo -e "[INFO]: Installing verilator"
  rm -rf $ROOT_DIR/verilator
  mkdir -p $ROOT_DIR/verilator
  cd $ROOT_DIR/verilator
  git clone https://github.com/verilator/verilator.git
  unset VERILATOR_ROOT
  cd verilator
  git pull
  git checkout v4.218
  autoconf
  ./configure --prefix=$ROOT_DIR/verilator
  make -j$(nproc)
  make test
  make install
  cd $ROOT_DIR/verilator
  rm -rf verilator
  echo -e ""
  echo -e "[INFO]: Put this command in your setup script:"
  echo -e " bash: export PATH=$ROOT_DIR/verilator/bin:\$PATH" 
  echo -e "  csh: setenv PATH $ROOT_DIR/verilator/bin:\$PATH" 
  echo -e ""
  echo -e "[INFO]: Check that it works with:"
  echo -e "      verilator --version"
  echo -e ""
else
  echo "[ERROR]: your arquitecture is NOT x86_64"
fi
