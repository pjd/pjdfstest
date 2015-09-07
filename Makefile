# $FreeBSD: head/tools/regression/pjdfstest/Makefile 248603 2013-03-21 23:07:04Z pjd $

CC?=		cc

OS_CFLAGS?=	-Wall

PROG=	pjdfstest

HAS_FREEBSD_ACL?=	-DHAS_FREEBSD_ACL

${PROG}:	${PROG}.c
	@OSTYPE=`uname`; \
	OS_CFLAGS=-D__OS_$${OSTYPE}__; \
	if [ $$OSTYPE = "FreeBSD" ]; then \
		OS_CFLAGS="$$OS_CFLAGS -DHAS_LCHMOD -DHAS_CHFLAGS -DHAS_FCHFLAGS -DHAS_LCHFLAGS -DHAS_POSIX_FALLOCATE ${HAS_FREEBSD_ACL}"; \
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
