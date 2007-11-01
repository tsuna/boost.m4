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

# ------ #
# README #
# ------ #

# This file provides several macros to use the various Boost libraries.
# The first macro is BOOST_REQUIRE.  It will simply check if it's possible to
# find the Boost headers of a given (optional) minimum version and it will
# define BOOST_CPPFLAGS accordingly.  It will add an option --with-boost to
# your configure so that users can specify non standard locations.

m4_pattern_forbid([^_?BOOST_])

# BOOST_REQUIRE([VERSION])
# ------------------------
# Look for Boost.  If version is given, it must either be a literal of the form
# "X.Y" where X and Y are integers or a variable "$var".
# Defines the value BOOST_CPPFLAGS.  This macro only checks for headers with
# the required version, it does not check for any of the Boost libraries.
# FIXME: Add a 2nd optionnal argument so that it's not fatal if Boost isn't found
# and add an AC_DEFINE to tell whether HAVE_BOOST.
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
    [boost_cv_inc_path],
    [boost_cv_inc_path=no
AC_LANG_PUSH([C++])dnl
    boost_subminor_chk=
    test x"$boost_version_subminor" != x \
      && boost_subminor_chk="|| (B_V_MAJ == $boost_version_major \
&& B_V_MIN == $boost_version_minor \
&& B_V_SUB % 100 < $boost_version_subminor)"
    for boost_inc in "$with_boost/include" '' \
             /opt/local/include /usr/local/include /opt/include /usr/include \
             "$with_boost" C:/Boost/include
    do
      test -e "$boost_inc" || continue
      boost_save_CPPFLAGS=$CPPFLAGS
      test x"$boost_inc" != x && CPPFLAGS="$CPPFLAGS -I$boost_inc"
m4_pattern_allow([^BOOST_VERSION$])dnl
      AC_COMPILE_IFELSE([AC_LANG_PROGRAM([[#include <boost/version.hpp>
#ifndef BOOST_VERSION
# error BOOST_VERSION is not defined
#endif
#define B_V_MAJ (BOOST_VERSION / 10000)
#define B_V_MIN (BOOST_VERSION / 100 % 1000)
#define B_V_SUB (BOOST_VERSION % 100)
#if (B_V_MAJ < $boost_version_major) \
   || (B_V_MAJ == $boost_version_major \
       && B_V_MIN / 100 % 1000 < $boost_version_minor) $boost_subminor_chk
# error Boost headers version < $1
#endif
]])], [boost_cv_inc_path=yes], [boost_cv_version=no])
      CPPFLAGS=$boost_save_CPPFLAGS
      if test x"$boost_cv_inc_path" = xyes; then
        if test x"$boost_inc" != x; then
          boost_cv_inc_path=$boost_inc
        fi
        break
      fi
    done
AC_LANG_POP([C++])dnl
    ])
    case $boost_cv_inc_path in #(
      no)
        AC_MSG_ERROR([Could not find Boost headers[]BOOST_VERSION_REQ])
        ;;#(
      yes)
        BOOST_CPPFLAGS=
        ;;#(
      *)
        BOOST_CPPFLAGS="-I$boost_cv_inc_path"
        ;;
    esac
AC_SUBST([BOOST_CPPFLAGS])dnl
  AC_CACHE_CHECK([for Boost's header version],
    [boost_cv_lib_version],
    [m4_pattern_allow([^BOOST_LIB_VERSION$])dnl
    boost_cv_lib_version=unknown
    boost_sed_version='/^.*BOOST_LIB_VERSION.*"\([[^"]]*\)".*$/!d;s//\1/'
    boost_version_hpp="$boost_inc/boost/version.hpp"
    test -e "$boost_version_hpp" \
      && boost_cv_lib_version=`sed "$boost_sed_version" "$boost_version_hpp"`
    ])
m4_popdef([BOOST_VERSION_REQ])dnl
])# BOOST_REQUIRE


# BOOST_FIND_HEADER([HEADER-NAME], [ACTION-IF-NOT-FOUND], [ACTION-IF-FOUND])
# --------------------------------------------------------------------------
# Wrapper around AC_CHECK_HEADER for Boost headers.  Useful to check for
# some parts of the Boost library which are only made of headers and don't
# require linking (such as Boost.Foreach).
#
# Default ACTION-IF-NOT-FOUND: Fail with a fatal error.
#
# Default ACTION-IF-FOUND: define the preprocessor symbol HAVE_<HEADER-NAME> in
# case of success # (where HEADER-NAME is written LIKE_THIS, e.g.,
# HAVE_BOOST_FOREACH_HPP).
AC_DEFUN([BOOST_FIND_HEADER],
[AC_REQUIRE([BOOST_REQUIRE])dnl
AC_LANG_PUSH([C++])dnl
boost_save_CPPFLAGS=$CPPFLAGS
CPPFLAGS="$CPPFLAGS $BOOST_CPPFLAGS"
AC_CHECK_HEADER([$1],
  [m4_default([$3], [AC_DEFINE(AS_TR_CPP([HAVE_$1]), [1],
                               [Define to 1 if you have <$1>])])],
  [m4_default([$2], [AC_MSG_ERROR([cannot find $1])])])
CPPFLAGS=$boost_save_CPPFLAGS
AC_LANG_POP([C++])dnl
])# BOOST_FIND_HEADER


# BOOST_FIND_LIB([LIB-NAME], [PREFERED-RT-OPT], [HEADER-NAME], [CXX-TEST])
# ------------------------------------------------------------------------
# Look for the Boost library LIB-NAME (e.g., LIB-NAME = `thread', for
# libboost_thread).  Check that HEADER-NAME works and check that
# libboost_LIB-NAME can link with the code CXX-TEST.
#
# Invokes BOOST_FIND_HEADER([HEADER-NAME]) (see above).
#
# Boost libraries typically come compiled with several flavors (with different
# runtime options) so PREFERED-RT-OPT is the prefered suffix.  A suffix is one
# or more of the following letters: sgdpn (in that order).  s = static
# runtime, d = debug build, g = debug/diagnostic runtime, p = STLPort build,
# n = (unsure) STLPort build without iostreams from STLPort (it looks like `n'
# must always be used along with `p').  Additionally, PREFERED-RT-OPT can
# start with `mt-' to indicate that there is a preference for multi-thread
# builds.  Some sample values for PREFERED-RT-OPT: (nothing), mt, d, mt-d, gdp
# ...  If you want to make sure you have a specific version of Boost
# (eg, >= 1.33) you *must* invoke BOOST_REQUIRE before this macro.
AC_DEFUN([BOOST_FIND_LIB],
[AC_REQUIRE([_BOOST_FIND_COMPILER_TAG])dnl
AC_REQUIRE([BOOST_REQUIRE])dnl
AC_LANG_PUSH([C++])dnl
AS_VAR_PUSHDEF([Boost_lib], [boost_cv_lib_$1])dnl
AS_VAR_PUSHDEF([Boost_lib_LDFLAGS], [boost_cv_lib_$1_LDFLAGS])dnl
AS_VAR_PUSHDEF([Boost_lib_LIBS], [boost_cv_lib_$1_LIBS])dnl
BOOST_FIND_HEADER([$3])
boost_save_CPPFLAGS=$CPPFLAGS
CPPFLAGS="$CPPFLAGS $BOOST_CPPFLAGS"
# Now let's try to find the library.  The algorithm is as follows: first look
# for a given library name according to the user's PREFERED-RT-OPT.  For each
# library name, we prefer to use the ones that carry the tag (toolset name).
# Each library is searched through the various standard paths were Boost is
# usually installed.  If we can't find the standard variants, we try to
# enforce -mt (for instance on MacOSX, libboost_threads.dylib doesn't exist
# but there's -obviously- libboost_threads-mt.dylib).
AC_CACHE_CHECK([for the Boost $1 library], [Boost_lib],
  [Boost_lib=no
  case "$2" in #(
    mt | mt-) boost_mt=-mt; boost_rtopt=;; #(
    mt* | mt-*) boost_mt=-mt; boost_rtopt=`expr "X$2" : 'Xmt-*\(.*\)'`;; #(
    *) boost_mt=; boost_rtopt=$2;;
  esac
  # If the PREFERED-RT-OPT are not empty, prepend a `-'.
  case $boost_rtopt in #(
    *[[a-z0-9A-Z]]*) boost_rtopt="-$boost_rtopt";;
  esac
  # Check whether we do better use `mt' even though we weren't ask to.
  if test x"$boost_mt" = x; then
    AC_COMPILE_IFELSE([AC_LANG_PROGRAM([[
#if defined _REENTRANT || defined _MT || defined __MT__
/* use -mt */
#else
# error MT not needed
#endif
]])], [boost_mt=-mt])
  fi
  # Generate the test file.
  AC_LANG_CONFTEST([AC_LANG_PROGRAM([#include <$3>], [$4])])
  boost_failed_libs=
# Don't bother to ident the 6 nested for loops, only the 2 insidemost ones
# matter.
for boost_tag_ in -$boost_cv_lib_tag ''; do
for boost_ver_ in -$boost_cv_lib_version ''; do
for boost_mt_ in $boost_mt -mt ''; do
for boost_rtopt_ in $boost_rtopt '' -d; do
  for boost_lib in \
    boost_$1$boost_tag_$boost_mt_$boost_rtopt_$boost_ver_ \
    boost_$1$boost_tag_$boost_mt_$boost_ver_ \
    boost_$1$boost_tag_$boost_rtopt_$boost_ver_ \
    boost_$1$boost_tag_$boost_mt_ \
    boost_$1$boost_tag_$boost_ver_
  do
    # Avoid testing twice the same lib
    case $boost_failed_libs in #(
      *@$boost_lib@*) continue;;
    esac
    boost_save_LIBS=$LIBS
    LIBS="-l$boost_lib $LIBS"
    for boost_ldpath in "$with_boost/lib" '' \
             /opt/local/lib /usr/local/lib /opt/lib /usr/lib \
             "$with_boost" C:/Boost/lib /lib /usr/lib64 /lib64
    do
      test -e "$boost_ldpath" || continue
      boost_save_LDFLAGS=$LDFLAGS
      test x"$boost_ldpath" != x && LDFLAGS="$LDFLAGS -L$boost_ldpath"
dnl First argument of AC_LINK_IFELSE left empty because the test file is
dnl generated only once above (before we start the for loops).
      AC_LINK_IFELSE([],
                     [Boost_lib=yes], [Boost_lib=no])
      if test x"$Boost_lib" = xyes; then
        Boost_lib_LDFLAGS="-L$boost_ldpath"
        Boost_lib_LIBS="-l$boost_lib"
        break 6
      else
        boost_failed_libs="$boost_failed_libs@$boost_lib@"
      fi
      LDFLAGS=$boost_save_LDFLAGS
    done
    LIBS=$boost_save_LIBS
  done
done
done
done
done
])
AC_SUBST(AS_TR_CPP([BOOST_$1_LDFLAGS]), [$Boost_lib_LDFLAGS])
AC_SUBST(AS_TR_CPP([BOOST_$1_LIBS]), [$Boost_lib_LIBS])
CPPFLAGS=$boost_save_CPPFLAGS
AS_VAR_POPDEF([Boost_lib])dnl
AS_VAR_POPDEF([Boost_lib_LDFLAGS])dnl
AS_VAR_POPDEF([Boost_lib_LIBS])dnl
AC_LANG_POP([C++])dnl
])# BOOST_FIND_LIB


# BOOST_FOREACH()
# ---------------
# Look for Boost.Foreach
AC_DEFUN([BOOST_FOREACH],
[BOOST_FIND_HEADER([boost/foreach.hpp])])


# BOOST_THREADS([PREFERED-RT-OPT])
# --------------------------------
# Look for Boost.Threads.  For the documentation of PREFERED-RT-OPT, see the
# documentation of BOOST_FIND_LIB above.
AC_DEFUN([BOOST_THREADS],
[BOOST_FIND_LIB([thread], [$1],
                [boost/thread.hpp], [boost::thread t; boost::mutex m;])
])#BOOST_THREADS


# _BOOST_FIND_COMPILER_TAG()
# --------------------------
# Internal.  When Boost is installed without --layout=system, each library
# filename will hold a suffix that encodes the compiler used during the
# build.  The Boost build system seems to call this a `tag'.
AC_DEFUN([_BOOST_FIND_COMPILER_TAG],
[AC_REQUIRE([AC_PROG_CXX])dnl
AC_CACHE_CHECK([for the toolset name used by Boost for $CXX], [boost_cv_lib_tag],
[AC_LANG_PUSH([C++])dnl
  boost_cv_lib_tag=unknown
  # The following tests are mostly inspired by boost/config/auto_link.hpp
  # The list is sorted to most recent/common to oldest compiler (in order
  # to increase the likelihood of finding the right compiler with the
  # least number of compilation attempt).
  # Beware that some tests are sensible to the order (for instance, we must
  # look for MinGW before looking for GCC3).
  # I used one compilation test per compiler with a #error to recognize
  # each compiler so that it works even when cross-compiling (let me know
  # if you know a better approach).
  # Known missing tags (known from Boost's tools/build/v2/tools/common.jam):
  #   como, edg, kcc, bck, mp, sw, tru, xlc
  # I'm not sure about my test for `il' (be careful: Intel's ICC pre-defines
  # the same defines as GCC's).
  for i in \
    "defined __GNUC__ && __GNUC__ == 4 && !defined __ICC @ gcc4" \
    "defined __GNUC__ && __GNUC__ == 3 && !defined __ICC \
     && (defined WIN32 || defined WINNT || defined _WIN32 || defined __WIN32 \
         || defined __WIN32__ || defined __WINNT || defined __WINNT__) @ mgw" \
    "defined __GNUC__ && __GNUC__ == 3 && !defined __ICC @ gcc3" \
    "defined _MSC_VER && _MSC_VER >= 1400 @ vc80" \
    "defined _MSC_VER && _MSC_VER == 1310 @ vc71" \
    "defined __BORLANDC__ @ bcb" \
    "defined __ICL @ iw" \
    "defined __ICC && (defined __unix || defined __unix__) @ il" \
    "defined _MSC_VER && _MSC_VER == 1300 @ vc7" \
    "defined __GNUC__ && __GNUC__ == 2 @ gcc2" \
    "defined __MWERKS__ && __MWERKS__ <= 0x32FF @ cw9" \
    "defined _MSC_VER && _MSC_VER < 1300 && !defined UNDER_CE @ vc6" \
    "defined _MSC_VER && _MSC_VER < 1300 && defined UNDER_CE @ evc4" \
    "defined __MWERKS__ && __MWERKS__ <= 0x31FF @ cw8"
  do
    boost_tag_test=`expr "X$i" : 'X\([[^@]]*\) @ '`
    boost_tag=`expr "X$i" : 'X[[^@]]* @ \(.*\)'`
    AC_COMPILE_IFELSE([AC_LANG_PROGRAM([[
#if $boost_tag_test
/* OK */
#else
# error $boost_tag_test
#endif
]])], [boost_cv_lib_tag=$boost_tag; break], [])
  done
AC_LANG_POP([C++])dnl
])
  if test x"$boost_cv_lib_tag" = xunknown; then
    AC_MSG_WARN([[could not figure out which toolset name to use for $CXX]])
    boost_cv_lib_tag=
  fi
])# _BOOST_FIND_COMPILER_TAG
