#
# Makefile for grepcidr
#

# Set to where you'd like grepcidr installed
INSTALLDIR=/usr/local/bin

# Set to your favorite C compiler and flags
# with GCC, -O3 makes a lot of difference
# -DDEBUG=1 prints out hex versions of IPs and matches

# Derive version from git tags, fallback to "unknown" if not in a git repo
VERSION := $(shell git describe --tags --always --dirty 2>/dev/null || echo "unknown")

CFLAGS=-O3 -Wall -pedantic -DVERSION=\"$(VERSION)\"
#CFLAGS=-g -Wall -pedantic -DDEBUG=1 -DVERSION=\"$(VERSION)\"
TFILES=COPYING ChangeLog Makefile README grepcidr.1 grepcidr.c
DIR!=basename ${PWD}

# End of settable values

all:	grepcidr

grepcidr:	grepcidr.c
	$(CC) $(CFLAGS) -o grepcidr grepcidr.c

install:	grepcidr
	cp grepcidr $(INSTALLDIR)

static: grepcidr.c
	$(CC) $(CFLAGS) -static -o grepcidr-static grepcidr.c

clean:
	rm -f grepcidr grepcidr-static

tar:
	cd ..; tar cvjf ${DIR}.tjz ${TFILES:C%^%${DIR}/%}
