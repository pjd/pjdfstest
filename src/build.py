from cffi import FFI
ffibuilder = FFI()

ffibuilder.cdef("""
    #define	O_WRONLY	0x0001
    #define	O_RDWR		0x0002
    #define	O_CREAT		0x0200

    struct stat {
        uint64_t  st_ino;
        int64_t	  st_size;
        ...;
    };

    int fstat(int fd, struct stat *sb);
    int open(const char *path, int flags, ...);
    int posix_fallocate(int fd, int64_t offset, int64_t len);
    int stat(const char * restrict path, struct stat * restrict sb);
    int symlink(const char *name1, const char *name2);
""")

ffibuilder.set_source("_libc",
"""
     #include "sys/stat.h"
     #include <fcntl.h>
     #include <unistd.h>
""",
     libraries=['c'])

if __name__ == "__main__":
    ffibuilder.compile(verbose=True)
