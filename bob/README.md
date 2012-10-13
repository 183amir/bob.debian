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

Upload the packages to our launchpad site:

```sh
$ dput ppa:biometrics/bob *.changes
```

Local builds
------------

You can run local builds using the script `local.sh`. Just configure it to your
needs.
