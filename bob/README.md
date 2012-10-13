Bob Package Construction
========================

Install the `devscripts` package:

```sh
$ sudo apt-get install devscripts
```

Edit the `make.sh` file to set the build properties and then, run it:

```sh
$ ./make.sh
```

Verify that the patches (if specific patches exists) in `os.files` are still
needed.

Upload the packages to our launchpad site, starting with the first version
that was packaged, as it will be the one containing bob sources:

If quantal:

```sh
$ dput ppa:biometrics/bob *quantal*.changes
```

Then the remaining ones, e.g.:

```sh
$ dput ppa:biometrics/bob *{precise,oneiric,maverick,natty,lucid}*.changes
```

Local builds
------------

You can run local builds using the script `local.sh`. Just configure it to your
needs.
