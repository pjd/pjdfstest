import argparse
import configparser
import grp
import os
import pwd
import secrets
import socket
import stat
import subprocess
import sys
import tempfile
import time
import unittest
from _libc import ffi, lib

modules = [
    'pjdfstest2.posix_fallocate',
    'pjdfstest2.symlink'
]

config = {
    "features": { },
    "naptime": 1.0
}

testdir = None

def require(feature):
    if config["features"][feature]:
        return lambda f: f
    else:
        return unittest.skip("%s not supported" % feature)

def require_root():
    if os.geteuid() == 0:
        return lambda f: f
    else:
        return unittest.skip("must be root")

def get_test_fs(testdir):
    """ Return the name of the file system under test """
    os = sys.platform
    if os.startswith("freebsd") or os.startswith("linux"):
        sp = subprocess.run(["df", "-T", testdir], capture_output=True)
        fs = sp.stdout.splitlines()[1].decode("utf-8").split()[1]
    else:
        raise "NotImplementedError"

    return fs

def set_default_features(testdir):
    global config

    """ Autoguess which features are supported by this OS/filesystem """
    os = sys.platform
    fs = get_test_fs(testdir)
    config["features"]["posix_fallocate"] = os.startswith("freebsd") and not fs.startswith("fusefs")

class BaseTestCase(unittest.TestCase):
    UNPRIVILEGED_FTYPES = ["reg", "dir", "fifo", "socket", "symlink"]
    PRIVILEGED_FTYPES = ["block", "char"]

    def setUp(self):
        self.dir = testdir

    def create_file(self, ftype, path):
        if ftype == "reg":
            fd = os.open(path, os.O_CREAT | os.O_EXCL, 0o644)
            self.assertTrue(fd >= 0)
        elif ftype == "dir":
            os.mkdir(path, 0o755)
        elif ftype == "fifo":
            os.mkfifo(path, 0o644)
        elif ftype == "block":
            os.mknod(path, stat.S_IFBLK | 0o644, os.makedev(1, 2))
        elif ftype == "char":
            os.mknod(path, stat.S_IFCHR | 0o644, os.makedev(1, 2))
        elif ftype == "socket":
            s = socket.socket(socket.AF_UNIX)
            s.bind(path)
        elif ftype == "symlink":
            os.symlink(path, path, "test")
        else:
            raise NotImplementedError

    def nap(self):
        """ Sleep for the minimum timestamp delta """
        time.sleep(config["naptime"])

    def remove_file(self, ftype, path):
        if ftype == "dir":
            fd = os.rmdir(path)
        else:
            os.unlink(path)

class OneFileTestCase(BaseTestCase):
    """ Test cases that operate on one temporary file """
    def setUp(self):
        BaseTestCase.setUp(self)
        self.file = tempfile.NamedTemporaryFile(dir=self.dir)
        self.fname = self.file.name.encode('utf-8')

    def fill(self, count):
        """ Fill the test file with count random bytes """
        # NB: in Python 3.9, replace secrets.token_bytes with random.randbytes
        self.file.write(secrets.token_bytes(12345))

@require_root()
class UnprivilegedTestCase(BaseTestCase):
    """ test case that drops privileges and runs in an accessible directory """
    def setUp(self):
        self.tempdir = tempfile.TemporaryDirectory(dir=testdir)
        self.dir = self.tempdir.name
        uid = pwd.getpwnam("nobody").pw_uid
        gid = grp.getgrnam("nogroup").gr_gid
        os.chmod(self.dir, 0o777)
        self.euid = os.geteuid()
        self.egid = os.getegid()
        os.setegid(gid)
        os.seteuid(uid)

    def tearDown(self):
        os.seteuid(self.euid)
        os.setegid(self.egid)

def main():
    global config
    global testdir

    parser = argparse.ArgumentParser()
    parser.add_argument('-f', '--config-file', dest='config_file',
                        type=str)
    parser.add_argument('-v', '--verbose', dest='verbosity',
                        action='store_const', const=2,
                        help='Verbose output')
    parser.add_argument('-q', '--quiet', dest='verbosity',
                        action='store_const', const=0,
                        help='Quiet output')
    parser.add_argument('dir', help='Directory to test')
    parser.add_argument('patterns', nargs="*",
            help="Only run tests which match the given substring")
    parser.set_defaults(verbosity=1)
    args = parser.parse_args()

    set_default_features(args.dir)

    if args.config_file:
        conffile = configparser.ConfigParser()
        conffile.read(args.config_file)
        for feature in conffile['features']:
            config["features"][feature] = conffile['features'].getboolean(feature)
        if conffile.has_option('settings', 'naptime'):
            config["naptime"] = float(conffile['settings']['naptime'])


    testdir = args.dir

    suite = unittest.TestSuite()
    for t in modules:
        loader = unittest.defaultTestLoader
        if len(args.patterns) > 0:
            loader.testNamePatterns = args.patterns
        suite.addTest(loader.loadTestsFromName(t))
    unittest.TextTestRunner(verbosity=args.verbosity).run(suite)
