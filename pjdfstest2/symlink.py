import errno
import os.path

from pjdfstest2 import *
from _libc import ffi, lib

class TestSymlink():
    def test_eexist(self):
        fname = os.path.join(self.dir,
                "TestSymlink::test_eexist").encode("utf-8")
        for ftype in self.FTYPES:
            with self.subTest(ftype=ftype):
                self.create_file(ftype, fname)
                try:
                    self.assertEqual(lib.symlink(b"test", fname), -1)
                    self.assertEqual(ffi.errno, errno.EEXIST)
                finally:
                    self.remove_file(ftype, fname)

class TestSymlink(BaseTestCase, TestSymlink):
    FTYPES = BaseTestCase.UNPRIVILEGED_FTYPES

@require_root()
class TestSymlinkPrivileged(TestSymlink):
    FTYPES = BaseTestCase.PRIVILEGED_FTYPES
