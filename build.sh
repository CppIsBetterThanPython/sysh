#!/usr/bin/env bash

nasm -f elf64 "$(pwd)/lib.asm" -o build/lib.o
nasm -f elf64 "$(pwd)/main.asm" -o build/main.o

ld build/lib.o build/main.o -o build/main
