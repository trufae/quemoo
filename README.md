# QueMoo

vm - stands for a tiny cow that says 'moooo'

## Description

This repository contains scripts that aims to simplify the setup
and use for new VMs for non-intel and non-linux centric operating
system shells.

This is, you can easily get a shell on OpenBSD-sparc64 or Linux-hppa
fully emulated in your local machine for development and testing
purposes.

There are a lot of projects for virtualizing Linux systems but don't
care about bizarre architectures. Not to say finding an easy way
to get shells on non-linux systems is not handy.

This project aims to solve all that.

## Status

Right now it's just a PoC written in a Makefile and supports the following targets:

```
+---------.-----------------.
|         | OpenBSD | Linux | 
|---------|-----------------|
| sparc64 |    x    |       |
| arm64   |    x    |       |
| ppc32   |         |   x   | ; openbsd bugs qemu with unhandled IRQs
| hppa    |         |       |
| mips    |         |       |
`---------'-----------------'
```

## Usage


Just run `make` and the name of the target you want to run, that will:

* create a 5GB qcow2 disk image
* download the installation ISOs/Disks
* run qemu in nographic mode
* add network adapter bridged to your lan

Options:

* expose serial console via TCP `CONSOLE=4450`
* configure amount of RAM `RAMSIZE=512` (in MB)
* configure disk size `DISKSIZE=5G`
* change `OPENBSD_VERSION=73`

```
$ make debian-ppc RAMSIZE=2G
```

or

```
$ make openbsd-sparc64
```
