# boost.m4: Locate Boost headers and libraries for autoconf-based projects.
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

# serial 1

# BOOST_REQUIRE([VERSION])
# ------------------------
# Look for Boost.  If version is given, it must either be a literal of the form
# "X.Y" where X and Y are integers or a variable "$var".
# Defines the value BOOST_CPPFLAGS.  This macro only checks for headers with
# the required version, it does not check for any of the Boost libraries.
AC_DEFUN([BOOST_REQUIRE],
[dnl First find out what kind of argument we have.
dnl If we have an empty argument, there is no constraint on the version of
dnl Boost to use.  If it's a literal version number, we can split it in M4 (so
dnl the resulting configure script will be smaller/faster).  Otherwise we do
dnl the splitting at runtime.
m4_bmatch([$1],
  [^ *$], [m4_pushdef([BOOST_VERSION_REQ], [])dnl
           boost_version_major=0
           boost_version_minor=0
           boost_version_subminor=0
],
  [^[0-9]+\([-._][0-9]+\)*$],
    [m4_pushdef([BOOST_VERSION_REQ], [ version >= $1])dnl
     boost_version_major=m4_bregexp([$1], [^\([0-9]+\)], [\1])
     boost_version_minor=m4_bregexp([$1], [^[0-9]+[-._]\([0-9]+\)], [\1])
     boost_version_subminor=m4_bregexp([$1], [^[0-9]+[-._][0-9]+[-._]\([0-9]+\)], [\1])
],
  [^\$[a-zA-Z_]+$],
    [m4_pushdef([BOOST_VERSION_REQ], [])dnl
     boost_version_major=`expr "X$1" : 'X\([[^-._]]*\)'`
     boost_version_minor=`expr "X$1" : 'X[[0-9]]*[[-._]]\([[^-._]]*\)'`
     boost_version_subminor=`expr "X$1" : 'X[[0-9]]*[[-._]][[0-9]]*[[-._]]\([[0-9]]*\)'`
     case $boost_version_major:$boost_version_minor in #(
       *: | :* | *[[^0-9]]*:* | *:*[[^0-9]]*)
         AC_MSG_ERROR([[Invalid argument for REQUIRE_BOOST: `$1']])
         ;;
     esac
],
  [m4_fatal(Invalid argument: `$1')]
)dnl
AC_ARG_WITH([boost],
   [AS_HELP_STRING([--with-boost=DIR],
                   [prefix of Boost]BOOST_VERSION_REQ[ @<:@guess@:>@])])dnl
  AC_CACHE_CHECK([for Boost headers[]BOOST_VERSION_REQ],
    [boost_cv_version],
    [boost_cv_version=no
AC_LANG_PUSH([C++])dnl
    boost_subminor_chk=
    test x"$boost_version_subminor" != x \
      && boost_subminor_chk="|| (BOOST_V_MAJ == $boost_version_major \
&& BOOST_V_MIN == $boost_version_minor \
&& BOOST_V_SUB % 100 < $boost_version_subminor)"
    for i in "$with_boost/include" '' \
             /opt/local/include /usr/local/include /opt/include /usr/include \
             "$with_boost" C:/Boost/include
    do
      boost_save_CPPFLAGS=$CPPFLAGS
      test x"$i" != x && CPPFLAGS="$CPPFLAGS -I$i"
      AC_COMPILE_IFELSE([AC_LANG_PROGRAM([[#include <boost/version.hpp>
#ifndef BOOST_VERSION
# error BOOST_VERSION is not defined
#endif
#define BOOST_V_MAJ (BOOST_VERSION / 10000)
#define BOOST_V_MIN (BOOST_VERSION / 100 % 1000)
#define BOOST_V_SUB (BOOST_VERSION % 100)
#if (BOOST_V_MAJ < $boost_version_major) \
   || (BOOST_V_MAJ == $boost_version_major \
       && BOOST_V_MIN / 100 % 1000 < $boost_version_minor) $boost_subminor_chk
# error Boost headers version < $1
#endif
]])], [boost_cv_version=yes], [boost_cv_version=no])
      CPPFLAGS=$boost_save_CPPFLAGS
      if test x"$boost_cv_version" = xyes; then
        if test x"$i" != x; then
          boost_cv_version=$i
        fi
        break
      fi
    done
AC_LANG_POP([C++])dnl
    ])
    case $boost_cv_version in #(
      no)
        AC_MSG_ERROR([Could not find Boost headers[]BOOST_VERSION_REQ])
        ;;#(
      yes)
        BOOST_CPPFLAGS=
        ;;#(
      *)
        BOOST_CPPFLAGS="-I$boost_cv_version"
        ;;
    esac
AC_SUBST([BOOST_CPPFLAGS])dnl
m4_popdef([BOOST_VERSION_REQ])dnl
])
