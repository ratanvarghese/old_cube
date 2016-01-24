CC=gcc
CFLAGS=-c -Wall -pedantic-errors -Werror -std=c11
LIBS=-llua -lncurses

CSRC=./src/
SRC=$(wildcard $(CSRC)*.c)
OBJ=$(SRC:%.c=%.o)
TESTDIR=./test/
TESTFILE=runall.sh

all: $(OBJ)
	$(CC) $(OBJ) $(LIBS) -o main

check:
	cp $(TESTDIR)$(TESTFILE) .
	sh $(TESTFILE)
	rm $(TESTFILE)

clean:
	rm $(OBJ) main
