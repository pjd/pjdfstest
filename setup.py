from setuptools import setup, find_packages

setup(
    setup_requires=["cffi>=1.0.0"],
    cffi_modules=["src/build.py:ffibuilder"],
    install_requires=["cffi>=1.0.0"],
    packages=find_packages(),
    entry_points = {
        'console_scripts': ['pjdfstest2 = pjdfstest2:main']
    },
)
