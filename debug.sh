#!/usr/bin/env bash

nasm -f elf64 -g -F dwarf "$(pwd)/lib.asm" -o debug/lib.o
nasm -f elf64 -g -F dwarf "$(pwd)/main.asm" -o debug/main.o

gcc -nostdlib -no-pie -g debug/main.o debug/lib.o -o debug/main
