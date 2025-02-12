#!/bin/bash

set -ouex pipefail

#https://docs.fedoraproject.org/en-US/bootc/home-directories/
mkdir -p -m 0700 /var/roothome

mv /opt /var/opt && \
  ln -s /var/opt /opt


mv /usr/local /var/usrlocal && \
  ln -s /var/usrlocal /usr/local

/tmp/kernel.sh

#cleanup
shopt -s extglob
rm -rf /var/roothome
rm -rf /var/!(cache)
rm -rf /var/cache/!(rpm-ostree)
rm -rf /var/tmp
dnf clean all
