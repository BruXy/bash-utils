SHELL = /bin/sh
CC=gcc
DEBUG=-ggdb3
OPT=-O3
CFLAGS=-Wall -pedantic -std=c99
CPPFLAGS=-Wall -pedantic -std=c++0x
LDFLAGS=

# Automatic variables
#
# https://monades.roperzh.com/rediscovering-make-automatic-variables/

# $@ ... targer name
# $< ... name of current prerequisite
# $? ... list of prerequisities newer than the target
# $^ ... list of all prerequisites

################################################################################

.SUFFIXES:
.SUFFIXES: .c .o

all: Makefile
	$(CC) $(CFLAGS)
		

################################################################################

.PHONY: all clean veryclean

clean:
	-rm *.o # prefix - means errors are ingored

veryclean: clean

