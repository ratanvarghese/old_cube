CC=gcc
CFLAGS=-c -Wall -pedantic-errors -Werror -std=c11
LIBS=-llua -lncurses

CSRC=./src/
SRC=$(wildcard $(CSRC)*.c)
OBJ=$(SRC:%.c=%.o)

all: $(OBJ)
	$(CC) $(OBJ) $(LIBS) -o main

clean:
	rm $(OBJ) main
