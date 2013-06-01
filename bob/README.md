Bob Package Construction
========================

Install the `devscripts` package:

```sh
$ sudo apt-get install devscripts debhelper
```

Edit the `make.sh` file to set the build properties and then, run it:

```sh
$ ./make.sh
```

Verify that the patches (if specific patches exists) in `os.files` are still
needed.

Upload the packages to our launchpad site, starting with the first version
that was packaged, as it will be the one containing bob sources:

```sh
$ source /etc/lsb-release
$ dput ppa:biometrics/bob *${DISTRIB_CODENAME}*.changes
```

Then the remaining ones, e.g.:

```sh
$ dput ppa:biometrics/bob *.changes
```

Local builds
------------

You can run local builds using the script `local.sh`. Just configure it to your
needs.

Managing patches
----------------

If you need to prepare patches for this package, do so using quilt
(http://pkg-perl.alioth.debian.org/howto/quilt.html). Prepare the patch on your
own, and then move it to the appropriate directory inside `os.files`.
