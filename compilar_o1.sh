#!/bin/bash
# Compila todos os arquivos VHDL da O1 (VHDL-2008)
set -e
cd "$(dirname "$0")"
mkdir -p build/o1
ghdl -a --std=08 --workdir=build/o1 o1/*.vhd
echo "O1 compilada sem erros"
