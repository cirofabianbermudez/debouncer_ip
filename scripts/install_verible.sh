#!/bin/bash

SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
ROOT_DIR=$(dirname "$SCRIPT_DIR")

echo -e "\n[INFO]: Checking dependencies"
DEPENDENCIES=("tar" "wget")
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
  echo -e "[INFO]: Installing Verible"
  rm -rf $ROOT_DIR/verible
  mkdir -p $ROOT_DIR/verible
  cd $ROOT_DIR/verible
  VERIBLE_VER=v0.0-3724-gdec56671
  wget -q https://github.com/chipsalliance/verible/releases/download/${VERIBLE_VER}/verible-${VERIBLE_VER}-linux-static-x86_64.tar.gz
  tar -xzf verible*.tar.gz
  mv verible-${VERIBLE_VER}/bin $ROOT_DIR/verible
  rm -rf verible*.tar.gz verible-${VERIBLE_VER}
  echo -e ""
  echo -e "[INFO]: Put this command in your setup script:"
  echo -e " bash: export PATH=$ROOT_DIR/verible/bin:\$PATH" 
  echo -e "  csh: setenv PATH $ROOT_DIR/verible/bin:\$PATH" 
  echo -e ""
  echo -e "[INFO]: Check that it works with:"
  echo -e "      verible-verilog-lint   --version"
  echo -e "      verible-verilog-format --version"
  echo -e "      verible-verilog-syntax --version"
  echo -e ""
else
  echo "[ERROR]: your arquitecture is NOT x86_64"
fi