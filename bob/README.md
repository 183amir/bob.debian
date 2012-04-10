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

Upload the packages to our launchpad site:

```sh
$ dput ppa:biometrics/bob *.changes
```

Building from Git
-----------------

When you build from the git repository, your tarball will not contain the
databases. Download the databases by modifying the script `pack.sh`, then:

```sh
$ ./pack.sh
```

To generate a valid `orig` package before running `make.sh` as explained above.

Local builds
------------

You can run local builds using the script `local.sh`. Just configure it to your
needs.
