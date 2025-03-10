# Copyright (C) 2007  Benoit Sigoure <tsuna@lrde.epita.fr>
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.

AC_INIT([boost-m4-test], [0.2], [tsunanet@gmail.com])
AC_CONFIG_AUX_DIR([build-aux])
AC_CONFIG_HEADERS([config.h])
AM_INIT_AUTOMAKE

AC_CANONICAL_HOST

LT_INIT

AC_PROG_GREP
AC_PROG_EGREP
AC_PROG_CXX

dnl First look for Boost, maybe for a specific minimum version:
BOOST_REQUIRE([1.34])
dnl Then look for specific Boost libraries you need:
BOOST_ARRAY
BOOST_DATE_TIME

# Initialize the test suite.
AC_CONFIG_TESTDIR([tests])
AM_MISSING_PROG([AUTOM4TE], [autom4te])

AC_CONFIG_FILES([
  Makefile
    tests/Makefile
    tests/atlocal
    tests/package.m4
])

AC_OUTPUT
