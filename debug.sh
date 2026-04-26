#!/usr/bin/env bash

SCRIPT_DIR="$(realpath "$(dirname "${BASH_SOURCE[0]}")")"

cd $SCRIPT_DIR

mkdir -p debug
# This has to be here otherwise macro libraries expload due to relative filenames
cd src

nasm -f elf64 -g -F dwarf "$(pwd)/lib.asm" -o ../debug/lib.o
nasm -f elf64 -g -F dwarf "$(pwd)/main.asm" -o ../debug/main.o

cd ../debug

gcc -nostdlib -no-pie -g main.o lib.o -o main
