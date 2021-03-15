import errno
import os.path
import sys
import tempfile
import unittest

from pjdfstest2 import *
from _libc import ffi, lib

@require("posix_fallocate")
class TestPosixFallocate(OneFileTestCase):
    def test_basic(self):
        fd = lib.open(self.fname, lib.O_RDWR);
        self.assertEqual(lib.posix_fallocate(fd, 0, 567), 0)
        self.assertEqual(os.path.getsize(self.fname), 567);

    def test_extend(self):
        self.fill(12345)
        fd = lib.open(self.fname, lib.O_RDWR);
        self.assertEqual(lib.posix_fallocate(fd, 20000, 3456), 0)
        self.assertEqual(os.path.getsize(self.fname), 23456);

    def test_update_ctime_on_success(self):
        ctime1 = os.path.getctime(self.fname)
        self.nap()
        fd = lib.open(self.fname, lib.O_RDWR);
        self.assertEqual(lib.posix_fallocate(fd, 0, 123), 0)
        ctime2 = os.path.getctime(self.fname)
        self.assertTrue(ctime1 < ctime2)

    def test_do_not_update_ctime_on_failure(self):
        ctime1 = os.path.getctime(self.fname)
        self.nap()
        fd = lib.open(self.fname, lib.O_WRONLY);
        self.assertEqual(lib.posix_fallocate(fd, 0, 0), errno.EINVAL)
        ctime2 = os.path.getctime(self.fname)
        self.assertEqual(ctime1, ctime2)

@require("posix_fallocate")
@require_root()
class TestPosixFallocateCreateRo():
    def test_create_ro(self):
        # posix_fallocate can mutate a newly created read-only file
        # https://bugs.freebsd.org/bugzilla/show_bug.cgi?id=154873
        fname = os.path.join(self.dir,
                "TestPosixFallocatePrivileged::test_create_ro").encode("utf-8")
        fd = lib.open(fname, lib.O_CREAT | lib.O_RDWR, ffi.cast("int", 0));
        self.assertTrue(fd >= 0);
        try:
            self.assertEqual(lib.posix_fallocate(fd, 0, 1), 0)
        finally:
            os.unlink(fname)

class TestPosixFallocatePrivileged(BaseTestCase, TestPosixFallocateCreateRo):
    pass

class TestPosixFallocateUnprivileged(UnprivilegedTestCase, TestPosixFallocateCreateRo):
    pass
