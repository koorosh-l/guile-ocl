GOBJECTS = $(SOURCES:%.scm=%.go) $(NODIST_SOURCES:%.scm=%.go)
nobase_mod_DATA = $(SOURCES) $(NOCOMP_SOURCES) $(NODIST_SOURCES)
nobase_go_DATA = $(GOBJECTS)

guile_install_go_files = install-nobase_goDATA
$(guile_install_go_files): install-nobase_modDATA

CLEANFILES = $(GOBJECTS)
EXTRA_DIST = $(SOURCES) $(NOCOMP_SOURCES)
GUILE_WARNINGS = -Wunbound-variable -Warity-mismatch -Wformat
SUFFIXES = .scm .go
.scm.go:
	$(AM_V_GEN)$(top_builddir)/pre-inst-env $(GUILE_TOOLS) compile --target="$(host)" $(GUILE_WARNINGS) -o "$@" "$<"

moddir=$(datadir)/guile/site/$(GUILE_EFFECTIVE_VERSION)
godir=$(libdir)/guile/$(GUILE_EFFECTIVE_VERSION)/site-ccache


SOURCES =		\
  cl.scm		\
  cl/array.scm		\
  cl/enums.scm		\
  cl/ffi.scm		\
  cl/functions.scm	\
  cl/spec.scm		\
  cl/structs.scm	\
  cl/types.scm		\
  cl/types/basic.scm	\
  cl/types/derived.scm	\
  cl/types/error.scm	\
  cl/types/info.scm	\
  cl/types/opaque.scm	\
  cl/config.scm


NODIST_SOURCES =	\
  cl/config.scm.in

CLEANFILES +=		\
  $(TESTS:tests/%.scm=%.log)

TEST_EXTENSIONS = .scm
SCM_LOG_COMPILER = $(top_builddir)/pre-inst-env $(GUILE)
AM_SCM_LOG_FLAGS = --no-auto-compile -L "$(top_srcdir)"

EXTRA_DIST +=		\
  pre-inst-env.in	\
  README.org
