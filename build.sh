#!/usr/bin/env bash

SCRIPT_DIR="$(realpath "$(dirname "${BASH_SOURCE[0]}")")"

cd $SCRIPT_DIR

mkdir -p build
# This has to be here otherwise macro libraries expload due to relative filenames
cd src

nasm -f elf64 "$(pwd)/lib.asm" -o ../build/lib.o
nasm -f elf64 "$(pwd)/main.asm" -o ../build/main.o

cd ../build

ld lib.o main.o -o main
