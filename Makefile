# $FreeBSD: head/tools/regression/pjdfstest/Makefile 219437 2011-03-09 22:39:10Z pjd $

CC?=		cc

CFLAGS?=	-Wall

PROG=	pjdfstest

${PROG}:	${PROG}.c
	@OSTYPE=`uname`; \
	OS_CFLAGS=-D__OS_$${OSTYPE}__; \
	if [ $$OSTYPE = "FreeBSD" ]; then \
		OS_CFLAGS="$$OS_CFLAGS -DHAS_LCHMOD -DHAS_CHFLAGS -DHAS_FCHFLAGS -DHAS_LCHFLAGS -DHAS_FREEBSD_ACL"; \
	elif [ $$OSTYPE = "SunOS" ]; then \
		OS_CFLAGS="$$OS_CFLAGS -DHAS_TRUNCATE64 -DHAS_STAT64"; \
		OS_LDLIBS="$$OS_LDLIBS -lsocket"; \
	elif [ $$OSTYPE = "Darwin" ]; then \
		OS_CFLAGS="$$OS_CFLAGS -DHAS_LCHMOD -DHAS_CHFLAGS -DHAS_LCHFLAGS"; \
	elif [ $$OSTYPE = "Linux" ]; then \
		OS_CFLAGS="$$OS_CFLAGS -D_GNU_SOURCE"; \
	else \
		echo "Unsupported operating system: ${OSTYPE}."; \
		exit 1; \
	fi; \
	cmd="${CC} $$OS_LDFLAGS $$OS_LDLIBS $$OS_CFLAGS ${PROG}.c -o ${PROG}"; \
	echo $$cmd; \
	$$cmd

all: ${PROG}

clean:
	rm -f ${PROG}
