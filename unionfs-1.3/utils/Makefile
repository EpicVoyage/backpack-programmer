# Makefile for the Linux 2.6 unionfs

BINS	:=	unionctl uniondbg unionimap
all:	${BINS}

unionctl: unionctl.c usercommon.c
	${CC} -o $@ $^ ${UCFLAGS}

uniondbg: uniondbg.c
	${CC} -o $@ $^ ${UCFLAGS}

unionimap: unionimap.c usercommon.c
	${CC} -o $@ $^ -luuid ${UCFLAGS}

TAGS: $(wildcard *.[ch])
	etags -t $^

tags: $(wildcard *.[ch])
	ctags $^

clean:
	rm -f ${BINS} TAGS tags

PHONY. utils: ${BINS}

install: utils
	mkdir -p ${PREFIX}/sbin
	cp unionctl ${PREFIX}/sbin
	cp uniondbg ${PREFIX}/sbin
	cp unionimap ${PREFIX}/sbin

uninstall:
	rm ${PREFIX}/sbin/unionctl
	rm ${PREFIX}/sbin/uniondbg
	rm ${PREFIX}/sbin/unionimap
