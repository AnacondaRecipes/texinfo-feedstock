#!/bin/bash

# A missing autopoint raises a non zero exit status during the configuration.
# This is part of gettext... which we don't build but should be part of glibc
# on linux. If execution is not stopped by this the package goes on to build
# just fine... not sure whether the configure stage can be tweaked to not
# insist that this functionality is present, even if just for a bootstrapping
# build of texinfo...
set +e
autoreconf -vfi
set -e

# We do this to prevent configure finding perl in the host prefix and
# using it in shebangs. /usr/bin/env <thing> is always the right thing
# for shebangs (and not just for us, everywhere else too).
PERL="/usr/bin/env perl" \
  ./configure --prefix=${PREFIX}

make -j${CPU_COUNT} ${VERBOSE_AT}
if [[ ${target_platform} != osx-64 ]]; then
  # https://github.com/NixOS/nixpkgs/issues/2338
  # https://angelika.me/2016/12/10/compressed-text-files/
  # /usr/bin/zdiff is used in the testsuite and the one Apple provides
  # does not work with bash (nice work Apple). We could provide
  # zutils instead: http://download.savannah.gnu.org/releases/zutils/
  # .. but for now ..
  make check
fi
make install
