SHELL:=/usr/bin/bash
CC=gcc
CFLAGS=-c -Wall -pedantic-errors -Werror -std=c99
LIBS=-llua -lncurses

CSRC=./src/
SRC=$(wildcard $(CSRC)*.c)
OBJ=$(SRC:%.c=%.o)
TESTDIR=./test/
TESTFILE=runall.sh

all: $(OBJ)
	$(CC) $(OBJ) $(LIBS) -o main

check:
	sh $(TESTDIR)$(TESTFILE)

clean:
	rm $(OBJ) main save/*
