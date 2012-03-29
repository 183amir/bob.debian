Building and Installing Bob Debian Packages
-------------------------------------------

To build the debian packages do the following:

```sh
$ debuild clean
$ dpkg-checkbuilddeps
$ debuild -us -uc -b
```

This will only quickly build the binary package as a test. To build all
packages, including the source package, do the following:

```sh
$ debuild --no-tgz-check -kA2170D5D -I.git -I.gitignore -I.gitmodules -I'cxx/visioner/project/*'
```

To only build the source package (for a PPA upload for instance). Replace the
"-kValue" by your own PPA key identifier (can be obtained with the command
`gpg --list-keys`) and append the -S:

```sh
$ debuild --no-tgz-check -kA2170D5D -I.git -I.gitignore -I.gitmodules -I'cxx/visioner/project/*' -S
```

The work of building a package with debuild can take some iterations.
Here are some tips to alleviate common problems:

1. To enable multiple processes when building:

  ```sh
	$ debuild -j4
  ```

2. To avoid cleaning before re-building (this will only rebuild the binary
   packages and not the source one):

  ```sh
	$ debuild -nc
  ```

	Note that, otherwise, debuild will first call clean.

3. To avoid signing the package (if you have a gpg key)

  ```sh
	$ debuild -us -uc
  ```

Once you are happy with the state of the package, just upload it to the PPA:

```sh
$ dput ppa:biometrics/bob ../bob_XYZ-0ubuntu1_source.changes
```

There are other ways to upload the package to the PPA, if you don't have dput
installed. Check here:

https://help.launchpad.net/Packaging/PPA/Uploading

Users can download and install PPAs as indicated at:

https://launchpad.net/~biometrics/+archive/bob
