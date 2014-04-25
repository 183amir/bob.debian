Blitz++ Package Construction
============================

Install the `devscripts` package:

```sh
$ sudo apt-get install devscripts debhelper dh-exec autotools-dev autoconf d-shlibs automake libtool gfortran
```

Edit the `make.sh` file to set the build properties and then, run it:

```sh
$ ./make.sh
```

Upload the packages to our launchpad site:

```sh
$ dput ppa:biometrics/bob *.changes
```
