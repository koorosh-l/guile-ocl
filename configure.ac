AC_INIT([guile-ocl], [0.0.1])
AC_CONFIG_SRCDIR([cl])
AC_CONFIG_AUX_DIR([build-aux])
AC_CONFIG_MACRO_DIR([m4])
AM_INIT_AUTOMAKE([-Wall -Werror foreign])
AM_SILENT_RULES([yes])
AC_CANONICAL_HOST
AC_CONFIG_FILES([Makefile cl/config.scm])
AC_CONFIG_FILES([pre-inst-env], [chmod +x pre-inst-env])
GUILE_PKG([3.0])
GUILE_PROGS
GUILE_SITE_DIR

PKG_CHECK_MODULES([OPENCL], [OpenCL], [], [
AC_MSG_FAILURE([OpenCL pkg-config not found])
])

PKG_CHECK_VAR([OPENCL_LIBDIR], [OpenCL], [libdir])
AC_MSG_CHECKING([OpenCL library path])
AS_IF([test "x$OPENCL_LIBDIR" = "x"], [
AC_MSG_FAILURE([Unable to identify OpenCL lib path.])
])
AC_SUBST([OPENCL_LIBDIR])

AC_OUTPUT
