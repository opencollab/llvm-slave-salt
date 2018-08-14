# LLVM salt states

This repository hosts salt states to configure servers related to Debian LLVM
packages.

## Jenkins at llvm-jenkins.debian.net

## Open Build Service at irill8.siege.inria.fr

This repository hosts salt states to provision our OBS intance at
irill8.siege.inria.fr.

For now, this OBS instance monitors the debian-devel-changes mailing list and
triggers Clang builds for newly accepted packages

### Adding new workers to the OBS instance

To configure new workers to our current OBS instance hosted at
irill8.siege.inria.fr, just set new salt slaves and provision them with
`obs-common` and `obs-worker`.

In this sense, the steps needed are: install the obs-worker package from Debian
Stable and substitute the `/etc/default/obsworker` configuration file with the
one provisioned by this repository.
