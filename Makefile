# ------------------------------------------------------------
# SWIG Examples Makefile
#
# This file is used by the examples to build modules.  Assuming
# you ran configure, this file will probably work.  However,
# it's not perfect so you might need to do some hand tweaking.
#
# Other notes:
#
# 1.   Take a look at the prefixes below.   Since SWIG works with
#      multiple target languages, you may need to find out where
#      certain packages have been installed.   Set the prefixes
#      accordingly.
#
# 2.   To use this makefile, set required variables, eg SRCS, INTERFACE,
#      INTERFACEDIR, INCLUDES, LIBS, TARGET, and do a
#           $(MAKE) -f Makefile.template.in SRCDIR='$(SRCDIR)' SRCS='$(SRCS)' \
#           INCLUDES='$(INCLUDES) LIBS='$(LIBS)' INTERFACE='$(INTERFACE)' \
#           INTERFACEDIR='$(INTERFACEDIR)' TARGET='$(TARGET)' method
#
#      'method' describes what is being built.
#---------------------------------------------------------------

# Regenerate Makefile if Makefile.in or config.status have changed.
Makefile: ./Makefile.in ../config.status
	cd .. && $(SHELL) ./config.status Examples/Makefile

# SRCDIR is the relative path to the current source directory
# - For in-source-tree builds, SRCDIR with be either '' or './', but
#   '../' for the test suites that build in a subdir (e.g. C#, Java)
# - For out-of-source-tree builds, SRCDIR will be a relative
#   path ending with a '/'

# SRCDIR_SRCS, etc. are $(SRCS), etc. with $(SRCDIR) prepended
SRCDIR_SRCS    = $(addprefix $(SRCDIR),$(SRCS))
SRCDIR_CSRCS   = $(addprefix $(SRCDIR),$(CSRCS))
SRCDIR_CXXSRCS = $(addprefix $(SRCDIR),$(CXXSRCS))

ifeq (,$(SRCDIR))
SRCDIR_INCLUDE = -I.
else
SRCDIR_INCLUDE = -I. -I$(SRCDIR)
endif

TARGET     =
CC         = gcc
CXX        = g++
CPPFLAGS   = $(SRCDIR_INCLUDE)
CFLAGS     = 
CXXFLAGS   = -I/usr/include 
LDFLAGS    =
prefix     = /home/tb246060/Documents/code/conda/conda2/envs/_build_placehold_placehold_place
exec_prefix= ${prefix}
SRCS       =
INCLUDES   =
LIBS       =
INTERFACE  =
INTERFACEDIR  =
INTERFACEPATH = $(SRCDIR)$(INTERFACEDIR)$(INTERFACE)
SWIGOPT    =

# SWIG_LIB_DIR and SWIGEXE must be explicitly set by Makefiles using this Makefile
SWIG_LIB_DIR = ./Lib
SWIGEXE    = swig
SWIG_LIB_SET = env SWIG_LIB=$(SWIG_LIB_DIR)
SWIGTOOL   =
SWIG       = $(SWIG_LIB_SET) $(SWIGTOOL) $(SWIGEXE)

LIBM       = -lieee -lm
LIBC       = 
LIBCRYPT   = -lcrypt
SYSLIBS    = $(LIBM) $(LIBC) $(LIBCRYPT)
LIBPREFIX  =

# RUNTOOL is for use with runtime tools, eg set it to valgrind
RUNTOOL    =
# COMPILETOOL is a way to run the compiler under another tool, or more commonly just to stop the compiler executing
COMPILETOOL=
# RUNPIPE is for piping output of running interpreter/compiled code somewhere, eg RUNPIPE=\>/dev/null
RUNPIPE=

RUNME = runme

IWRAP      = $(INTERFACE:.i=_wrap.i)
ISRCS      = $(IWRAP:.i=.c)
ICXXSRCS   = $(IWRAP:.i=.cxx)
IOBJS      = $(IWRAP:.i=.o)

##################################################################
# Some options for silent output
##################################################################

ifneq (,$(findstring s, $(filter-out --%, $(MAKEFLAGS))))
  # make -s detected
  SILENT=1
else
  SILENT=
endif

ifneq (,$(SILENT))
  SILENT_OPTION = -s
  SILENT_PIPE = >/dev/null
  ANT_QUIET = -q -logfile /dev/null
else
  SILENT_OPTION =
  SILENT_PIPE =
  ANT_QUIET =
endif

##################################################################
# Dynamic loading for C++
# If you are going to be building dynamic loadable modules in C++,
# you may need to edit this line appropriately.
#
# This line works for g++, but I'm not sure what it might be
# for other C++ compilers
##################################################################

CPP_DLLIBS = #-L/usr/local/lib/gcc-lib/sparc-sun-solaris2.5.1/2.7.2 \
	     -L/usr/local/lib -lg++ -lstdc++ -lgcc

# Solaris workshop 5.0
# CPP_DLLIBS = -L/opt/SUNWspro/lib -lCrun

# Symbols used for using shared libraries
SO=		.so
LDSHARED=	gcc -shared
CCSHARED=	-fpic
CXXSHARED=      gcc -shared

# This is used for building shared libraries with a number of C++
# compilers.   If it doesn't work,  comment it out.
CXXSHARED= g++ -shared 

OBJS      = $(SRCS:.c=.o) $(CXXSRCS:.cxx=.o)

distclean:
	rm -f Makefile
	rm -f d/example.mk
	rm -f xml/Makefile

##################################################################
# Very generic invocation of swig
##################################################################

swiginvoke:
	$(SWIG) $(SWIGOPT)

##################################################################
#####                       Tcl/Tk                          ######
##################################################################

# Set these to your local copy of Tcl/Tk.

TCLSH       = tclsh
TCL_INCLUDE = 
TCL_LIB     = 
TCL_OPTS    = -ldl  -L/home/tb246060/Documents/code/conda/conda2/envs/_build_placehold_placehold_place/lib -lpcre
TK_OPTS     = -ltk -ltcl -ldl  -L/home/tb246060/Documents/code/conda/conda2/envs/_build_placehold_placehold_place/lib -lpcre

# Extra Tcl specific dynamic linking options
TCL_DLNK   = 
TCL_SO     = .so
TCLLDSHARED = $(LDSHARED)
TCLCXXSHARED = $(CXXSHARED)
TCL_SCRIPT = $(SRCDIR)$(RUNME).tcl

# -----------------------------------------------------------
# Build a new version of the tclsh shell
# -----------------------------------------------------------

tclsh: $(SRCDIR_SRCS)
	$(SWIG) -tcl8 $(SWIGOPT) $(TCL_SWIGOPTS) -ltclsh.i -o $(ISRCS) $(INTERFACEPATH)
	$(CC) $(CPPFLAGS) $(CFLAGS) $(LDFLAGS) $(SRCDIR_SRCS) $(ISRCS) $(INCLUDES) $(TCL_INCLUDE) \
	$(TCL_LIB)  $(TCL_OPTS) $(LIBS) $(SYSLIBS) -o $(TARGET)

tclsh_cpp: $(SRCDIR_SRCS)
	$(SWIG) -tcl8 -c++ $(SWIGOPT) $(TCL_SWIGOPTS) -ltclsh.i -o $(ICXXSRCS) $(INTERFACEPATH)
	$(CXX) $(CPPFLAGS) $(CXXFLAGS) $(LDFLAGS) $(SRCDIR_SRCS) $(SRCDIR_CXXSRCS) $(ICXXSRCS) $(INCLUDES) $(TCL_INCLUDE) \
	$(TCL_LIB) $(TCL_OPTS) $(LIBS) $(SYSLIBS) -o $(TARGET)

# -----------------------------------------------------------
# Build a Tcl dynamic loadable module (you might need to tweak this)
# -----------------------------------------------------------

tcl:  $(SRCDIR_SRCS)
	$(SWIG) -tcl8 $(SWIGOPT) $(TCL_SWIGOPTS) -o $(ISRCS) $(INTERFACEPATH)
	$(CC) -c $(CCSHARED) $(CPPFLAGS) $(CFLAGS) $(SRCDIR_SRCS) $(ISRCS) $(INCLUDES) $(TCL_INCLUDE)
	$(TCLLDSHARED) $(CFLAGS) $(LDFLAGS) $(OBJS) $(IOBJS) $(TCL_DLNK) $(LIBS) -o $(LIBPREFIX)$(TARGET)$(TCL_SO)

# -----------------------------------------------------------
# Build a Tcl7.5 dynamic loadable module for C++
# -----------------------------------------------------------

tcl_cpp: $(SRCDIR_SRCS)
	$(SWIG) -tcl8 -c++ $(SWIGOPT) $(TCL_SWIGOPTS) -o $(ICXXSRCS) $(INTERFACEPATH)
	$(CXX) -c $(CCSHARED) $(CPPFLAGS) $(CXXFLAGS) $(SRCDIR_SRCS) $(SRCDIR_CXXSRCS) $(ICXXSRCS) $(INCLUDES) $(TCL_INCLUDE)
	$(TCLCXXSHARED) $(CXXFLAGS) $(LDFLAGS) $(OBJS) $(IOBJS) $(TCL_DLNK) $(LIBS) $(CPP_DLLIBS) -o $(LIBPREFIX)$(TARGET)$(TCL_SO)

# -----------------------------------------------------------------
# Run Tcl example
# -----------------------------------------------------------------

tcl_run:
	$(RUNTOOL) $(TCLSH) $(TCL_SCRIPT) $(RUNPIPE)

# -----------------------------------------------------------------
# Version display
# -----------------------------------------------------------------

tcl_version:
	echo 'puts $$tcl_version;exit 0' | $(TCLSH)

# -----------------------------------------------------------------
# Cleaning the Tcl examples
# -----------------------------------------------------------------

tcl_clean:
	rm -f *_wrap* *~ .~* mytclsh
	rm -f core 
	rm -f *.o *$(TCL_SO)

##################################################################
#####                       PERL 5                          ######
##################################################################

# You need to set this variable to the Perl5 directory containing the
# files "perl.h", "EXTERN.h" and "XSUB.h".   With Perl5.003, it's
# usually something like /usr/local/lib/perl5/arch-osname/5.003/CORE.

PERL5_INCLUDE= /usr/lib/x86_64-linux-gnu/perl/5.22/CORE

# Extra Perl specific dynamic linking options
PERL5_DLNK   = 
PERL5_CCFLAGS = -D_REENTRANT -D_GNU_SOURCE -DDEBIAN -fwrapv -fno-strict-aliasing -pipe -isystem /usr/local/include -D_LARGEFILE_SOURCE -D_FILE_OFFSET_BITS=64
PERL5_CCDLFLAGS = -Wl,-E
PERL5_CCCDLFLAGS = -fPIC
PERL5_LDFLAGS =  -fstack-protector-strong -L/usr/local/lib
PERL = perl
PERL5_LIB = -L$(PERL5_INCLUDE) -lperl -ldl  -L/home/tb246060/Documents/code/conda/conda2/envs/_build_placehold_placehold_place/lib -lpcre $(SYSLIBS)
PERL5_SCRIPT = $(SRCDIR)$(RUNME).pl

# ----------------------------------------------------------------
# Build a Perl5 dynamically loadable module (C)
# ----------------------------------------------------------------

perl5: $(SRCDIR_SRCS)
	$(SWIG) -perl5 $(SWIGOPT) -o $(ISRCS) $(INTERFACEPATH)
	$(CC) -c -Dbool=char $(CCSHARED) $(CPPFLAGS) $(CFLAGS) $(SRCDIR_SRCS) $(ISRCS) $(INCLUDES) $(PERL5_CCFLAGS) $(PERL5_CCCDLFLAGS) -I$(PERL5_INCLUDE)
	$(LDSHARED) $(CFLAGS) $(LDFLAGS) $(PERL5_CCDLFLAGS) $(OBJS) $(IOBJS) $(PERL5_LDFLAGS) $(PERL5_DLNK) $(LIBS) -o $(LIBPREFIX)$(TARGET)$(SO)

# ----------------------------------------------------------------
# Build a Perl5 dynamically loadable module (C++)
# ----------------------------------------------------------------

perl5_cpp: $(SRCDIR_SRCS)
	$(SWIG) -perl5 -c++ $(SWIGOPT) -o $(ICXXSRCS) $(INTERFACEPATH)
	$(CXX) -c $(CCSHARED) $(CPPFLAGS) $(CXXFLAGS) $(SRCDIR_SRCS) $(SRCDIR_CXXSRCS) $(ICXXSRCS) $(INCLUDES) $(PERL5_CCFLAGS) $(PERL5_CCCDLFLAGS) -I$(PERL5_INCLUDE)
	$(CXXSHARED) $(CXXFLAGS) $(LDFLAGS) $(PERL5_CCDLFLAGS) $(OBJS) $(IOBJS) $(PERL5_LDFLAGS) $(PERL5_DLNK) $(LIBS) $(CPP_DLLIBS) -o $(LIBPREFIX)$(TARGET)$(SO)

# ----------------------------------------------------------------
# Build a module from existing XS C source code.   (ie. from xsubpp).
# ----------------------------------------------------------------
perl5_xs: $(SRCDIR_SRCS)
	$(CC) -c $(CCSHARED) $(CPPFLAGS) $(CFLAGS) $(SRCDIR_SRCS) $(INCLUDES) -I$(PERL5_INCLUDE)
	$(LDSHARED) $(CFLAGS) $(LDFLAGS) $(OBJS) $(LIBS) -o $(TARGET)$(SO)

# ----------------------------------------------------------------
# Build a statically linked Perl5 executable
# ----------------------------------------------------------------

perl5_static: $(SRCDIR_SRCS)
	$(SWIG) -perl5 -static -lperlmain.i $(SWIGOPT) -o $(ISRCS) $(INTERFACEPATH)
	$(CC) $(CPPFLAGS) $(CFLAGS) $(LDFLAGS) -Dbool=char $(SRCDIR_SRCS) $(ISRCS) $(INCLUDES) -I$(PERL5_INCLUDE) $(PERL5_LIB) $(LIBS) -o $(TARGET)

perl5_static_cpp: $(SRCDIR_SRCS)
	$(SWIG) -perl5 -c++ -static -lperlmain.i $(SWIGOPT) -o $(ICXXSRCS) $(INTERFACEPATH)
	$(CXX) $(CPPFLAGS) $(CXXFLAGS) $(LDFLAGS) $(SRCDIR_SRCS) $(SRCDIR_CXXSRCS) $(ICXXSRCS) $(INCLUDES) -I$(PERL5_INCLUDE) $(PERL5_LIB) $(LIBS) -o $(TARGET)

# -----------------------------------------------------------------
# Running a Perl5 example
# -----------------------------------------------------------------

perl5_run:
	$(RUNTOOL) $(PERL) $(PERL5_SCRIPT) $(RUNPIPE)

# -----------------------------------------------------------------
# Version display
# -----------------------------------------------------------------

perl5_version:
	$(PERL) -v | grep "This is"

# -----------------------------------------------------------------
# Cleaning the Perl5 examples
# -----------------------------------------------------------------

perl5_clean:
	rm -f *_wrap* *~ .~* myperl *.pm
	rm -f core 
	rm -f *.o *.so

##################################################################
#####                       PYTHON                          ######
##################################################################

PYTHON_FLAGS =

# Make sure these locate your Python installation
ifeq (,$(PY3))
  PYTHON_INCLUDE= $(DEFS) -I/home/tb246060/Documents/code/conda/conda2/envs/_build_placehold_placehold_place/include/python2.7 -I/home/tb246060/Documents/code/conda/conda2/envs/_build_placehold_placehold_place/lib/python2.7/config
  PYTHON_LIB    = /home/tb246060/Documents/code/conda/conda2/envs/_build_placehold_placehold_place/lib/python2.7/config
  PYTHON        = /home/tb246060/Documents/code/conda/conda2/envs/_build_placehold_placehold_place/bin/python $(PYTHON_FLAGS)
else
  PYTHON_INCLUDE= $(DEFS) -I/home/tb246060/Documents/code/conda/conda2/envs/py3/include/python3.5m -I/home/tb246060/Documents/code/conda/conda2/envs/py3/include/python3.5m
  PYTHON_LIB    = 
  PYTHON        = python3 $(PYTHON_FLAGS)
endif

# Extra Python specific linking options
ifeq (,$(PY3))
  PYTHON_DLNK   = 
  PYTHON_LINK   = -lpython2.7
else
  PYTHON_DLNK   = 
  PYTHON_LINK   = -lpython3.5
endif
PYTHON_SO     = .so

# SWIG option for Python
ifeq (,$(PY3))
  SWIGPYTHON = $(SWIG) -python
else
  SWIGPYTHON = $(SWIG) -python -py3
endif

PEP8         = pep8
PEP8_FLAGS   = --ignore=E402,E501,E30,W291,W391

# ----------------------------------------------------------------
# Build a C dynamically loadable module
# ----------------------------------------------------------------

python: $(SRCDIR_SRCS)
	$(SWIGPYTHON) $(SWIGOPT) -o $(ISRCS) $(INTERFACEPATH)
	$(CC) -c $(CCSHARED) $(CPPFLAGS) $(CFLAGS) $(ISRCS) $(SRCDIR_SRCS) $(INCLUDES) $(PYTHON_INCLUDE)
	$(LDSHARED) $(CFLAGS) $(LDFLAGS) $(OBJS) $(IOBJS) $(PYTHON_DLNK) $(LIBS) -o $(LIBPREFIX)_$(TARGET)$(PYTHON_SO)

# -----------------------------------------------------------------
# Build a C++ dynamically loadable module
# -----------------------------------------------------------------

python_cpp: $(SRCDIR_SRCS)
	$(SWIGPYTHON) -c++ $(SWIGOPT) -o $(ICXXSRCS) $(INTERFACEPATH)
	$(CXX) -c $(CCSHARED) $(CPPFLAGS) $(CXXFLAGS) $(ICXXSRCS) $(SRCDIR_SRCS) $(SRCDIR_CXXSRCS) $(INCLUDES) $(PYTHON_INCLUDE)
	$(CXXSHARED) $(CXXFLAGS) $(LDFLAGS) $(OBJS) $(IOBJS) $(PYTHON_DLNK) $(LIBS) $(CPP_DLLIBS) -o $(LIBPREFIX)_$(TARGET)$(PYTHON_SO)

# -----------------------------------------------------------------
# Build statically linked Python interpreter
#
# These should only be used in conjunction with the %include embed.i
# library file
# -----------------------------------------------------------------

#TKINTER = -L/usr/X11R6.3/lib -L/usr/local/compat/lib -ltk4.0 -ltcl7.4 -lX11
TKINTER =
PYTHON_LIBOPTS = $(PYTHON_LINK) -ldl  -L/home/tb246060/Documents/code/conda/conda2/envs/_build_placehold_placehold_place/lib -lpcre $(TKINTER) $(SYSLIBS)

python_static: $(SRCDIR_SRCS)
	$(SWIGPYTHON) -lembed.i $(SWIGOPT) -o $(ISRCS) $(INTERFACEPATH)
	$(CC) $(CPPFLAGS) $(CFLAGS) $(LDFLAGS) -Xlinker -export-dynamic $(ISRCS) $(SRCDIR_SRCS) $(INCLUDES) \
	$(PYTHON_INCLUDE) $(LIBS) -L$(PYTHON_LIB) $(PYTHON_LIBOPTS) -o $(TARGET)

python_static_cpp: $(SRCDIR_SRCS)
	$(SWIGPYTHON) -c++ -lembed.i $(SWIGOPT) -o $(ICXXSRCS) $(INTERFACEPATH)
	$(CXX) $(CPPFLAGS) $(CXXFLAGS) $(LDFLAGS) $(ICXXSRCS) $(SRCDIR_SRCS) $(SRCDIR_CXXSRCS) $(INCLUDES) \
	$(PYTHON_INCLUDE) $(LIBS)  -L$(PYTHON_LIB) $(PYTHON_LIBOPTS) -o $(TARGET)

# -----------------------------------------------------------------
# Running a Python example
# -----------------------------------------------------------------

ifeq (,$(PY3))
  PYSCRIPT = $(RUNME).py
else
  PYSCRIPT = $(RUNME)3.py
endif

PY2TO3 = 2to3 `2to3 -l | grep -v -E "Available|import$$" | awk '{print "-f "$$0}'`

python_run: $(PYSCRIPT)
ifneq (,$(PEP8))
	$(COMPILETOOL) $(PEP8) $(PEP8_FLAGS) $(PYSCRIPT)
endif
	env PYTHONPATH=$$PWD $(RUNTOOL) $(PYTHON) $(PYSCRIPT) $(RUNPIPE)

ifneq (,$(SRCDIR))
$(RUNME).py: $(SRCDIR)$(RUNME).py
	cp $< $@
endif

$(RUNME)3.py: $(SRCDIR)$(RUNME).py
	cp $< $@
	$(PY2TO3) -w $@ >/dev/null 2>&1

# -----------------------------------------------------------------
# Version display
# -----------------------------------------------------------------

python_version:
	$(PYTHON) -V

# -----------------------------------------------------------------
# Cleaning the python examples
# -----------------------------------------------------------------

python_clean:
	rm -rf __pycache__
	rm -f *_wrap* *~ .~* mypython *.pyc
	rm -f core 
	rm -f *.o *.so *$(PYTHON_SO)
	rm -f $(TARGET).py
	if test -f $(SRCDIR)$(RUNME).py; then rm -f $(RUNME)3.py $(RUNME)3.py.bak; fi
	case "x$(SRCDIR)" in x|x./);; *) rm -f $(RUNME).py;; esac


##################################################################
#####                       OCTAVE                          ######
##################################################################

# Make sure these locate your Octave installation
OCTAVE        = 
OCTAVE_CXX    = $(DEFS)  

# Extra Octave specific dynamic linking options
OCTAVE_DLNK   = 
OCTAVE_SO     = .oct

OCTAVE_SCRIPT = $(SRCDIR)$(RUNME).m

# ----------------------------------------------------------------
# Build a C dynamically loadable module
# Note: Octave requires C++ compiler when compiling C wrappers
# ----------------------------------------------------------------

octave: $(SRCDIR_SRCS)
	$(SWIG) -octave $(SWIGOPT) -o $(ICXXSRCS) $(INTERFACEPATH)
	$(CXX) -g -c $(CCSHARED) $(CPPFLAGS) $(CXXFLAGS) $(ICXXSRCS) $(INCLUDES) $(OCTAVE_CXX)
	$(CC) -g -c $(CCSHARED) $(CPPFLAGS) $(CFLAGS) $(SRCDIR_SRCS) $(SRCDIR_CSRCS) $(INCLUDES)
	$(LDSHARED) $(CFLAGS) $(LDFLAGS) $(OBJS) $(IOBJS) $(OCTAVE_DLNK) $(LIBS) -o $(LIBPREFIX)$(TARGET)$(OCTAVE_SO)

# -----------------------------------------------------------------
# Build a C++ dynamically loadable module
# -----------------------------------------------------------------

octave_cpp: $(SRCDIR_SRCS)
	$(SWIG) -c++ -octave $(SWIGOPT) -o $(ICXXSRCS) $(INTERFACEPATH)
	$(CXX) -g -c $(CCSHARED) $(CPPFLAGS) $(CXXFLAGS) $(ICXXSRCS) $(SRCDIR_SRCS) $(SRCDIR_CXXSRCS) $(INCLUDES) $(OCTAVE_CXX)
	$(CXXSHARED) -g $(CXXFLAGS) $(LDFLAGS) $(OBJS) $(IOBJS) $(OCTAVE_DLNK) $(LIBS) $(CPP_DLLIBS) -o $(LIBPREFIX)$(TARGET)$(OCTAVE_SO)

# -----------------------------------------------------------------
# Running an Octave example
# -----------------------------------------------------------------

octave_run:
	OCTAVE_HISTFILE=/dev/null $(RUNTOOL) $(OCTAVE) $(OCTAVE_SCRIPT) $(RUNPIPE)

# -----------------------------------------------------------------
# Version display
# -----------------------------------------------------------------

octave_version:
	$(OCTAVE) --version | head -n 1

# -----------------------------------------------------------------
# Cleaning the Octave examples
# -----------------------------------------------------------------

octave_clean:
	rm -rf __pycache__
	rm -f *_wrap* *~ .~* myoctave *.pyc
	rm -f core 
	rm -f *.o *.so *$(OCTAVE_SO)

##################################################################
#####                       GUILE                           ######
##################################################################

# Make sure these locate your Guile installation
GUILE         = yes
GUILE_CFLAGS  = 
GUILE_SO      = .so
GUILE_LIBS    = 
GUILE_LIBOPTS = -ldl  -L/home/tb246060/Documents/code/conda/conda2/envs/_build_placehold_placehold_place/lib -lpcre $(SYSLIBS)
GUILE_LIBPREFIX = lib
GUILE_SCRIPT  = $(SRCDIR)$(RUNME).scm

#------------------------------------------------------------------
# Build a dynamically loaded module with passive linkage
#------------------------------------------------------------------
guile: $(SRCDIR_SRCS)
	$(SWIG) -guile -Linkage passive $(SWIGOPT) -o $(ISRCS) $(INTERFACEPATH)
	$(CC) -c $(CCSHARED) $(CPPFLAGS) $(CFLAGS) $(INCLUDES) $(GUILE_CFLAGS) $(ISRCS) $(SRCDIR_SRCS)
	$(LDSHARED) $(CFLAGS) $(LDFLAGS) $(OBJS) $(IOBJS) $(GUILE_LIBS) $(LIBS) -o $(GUILE_LIBPREFIX)$(TARGET)$(GUILE_SO)

guile_cpp: $(SRCDIR_SRCS)
	$(SWIG) -c++ -guile -Linkage passive $(SWIGOPT) -o $(ICXXSRCS) $(INTERFACEPATH)
	$(CXX) -c $(CCSHARED) $(CPPFLAGS) $(CXXFLAGS) $(INCLUDES) $(GUILE_CFLAGS) $(ICXXSRCS) $(SRCDIR_SRCS) $(SRCDIR_CXXSRCS)
	$(CXXSHARED) $(CXXFLAGS) $(LDFLAGS) $(OBJS) $(IOBJS) $(GUILE_LIBS) $(LIBS) $(CPP_DLLIBS) -o $(GUILE_LIBPREFIX)$(TARGET)$(GUILE_SO)

guile_externalhdr:
	$(SWIG) -guile -external-runtime $(TARGET)

# -----------------------------------------------------------------
# Build Guile interpreter augmented with extra functions
# -----------------------------------------------------------------

guile_augmented: $(SRCDIR_SRCS)
	$(SWIG) -guile $(SWIGOPT) -o $(ISRCS) $(INTERFACEPATH)
	$(CC) $(CPPFLAGS) $(CFLAGS) $(LDFLAGS) $(SRCDIR_SRCS) $(ISRCS) $(GUILE_CFLAGS) $(GUILE_LIBS) $(LIBS) -o $(TARGET)

# -----------------------------------------------------------------
# Build statically linked Guile interpreter
# -----------------------------------------------------------------

guile_static: $(SRCDIR_SRCS)
	$(SWIG) -guile -lguilemain.i -Linkage ltdlmod $(SWIGOPT) -o $(ISRCS) $(INTERFACEPATH)
	$(CC) $(CPPFLAGS) $(CFLAGS) $(LDFLAGS) $(ISRCS) $(SRCDIR_SRCS) $(INCLUDES) \
	  -DSWIGINIT="SCM scm_init_$(TARGET)_module(void); scm_init_$(TARGET)_module();" \
	  $(GUILE_CFLAGS) $(GUILE_LIBS) $(LIBS) $(GUILE_LIBOPTS) -o $(TARGET)-guile

guile_static_cpp: $(SRCDIR_SRCS)
	$(SWIG) -c++ -guile -lguilemain.i -Linkage ltdlmod $(SWIGOPT) -o $(ICXXSRCS) $(INTERFACEPATH)
	$(CXX) $(CPPFLAGS) $(CXXFLAGS) $(LDFLAGS) $(ICXXSRCS) $(SRCDIR_SRCS) $(SRCDIR_CXXSRCS) $(INCLUDES) \
	  -DSWIGINIT="SCM scm_init_$(TARGET)_module(void); scm_init_$(TARGET)_module();" \
	  $(GUILE_CFLAGS) $(GUILE_LIBS) $(LIBS) $(GUILE_LIBOPTS) -o $(TARGET)-guile

guile_simple: $(SRCDIR_SRCS)
	$(SWIG) -guile -lguilemain.i -Linkage simple $(SWIGOPT) -o $(ISRCS) $(INTERFACEPATH)
	$(CC) $(CPPFLAGS) $(CFLAGS) $(LDFLAGS) $(ISRCS) $(SRCDIR_SRCS) $(INCLUDES) \
	  $(GUILE_CFLAGS) $(GUILE_LIBS) $(LIBS) $(GUILE_LIBOPTS) -o $(TARGET)-guile

guile_simple_cpp: $(SRCDIR_SRCS)
	$(SWIG) -c++ -guile -lguilemain.i -Linkage simple $(SWIGOPT) -o $(ICXXSRCS) $(INTERFACEPATH)
	$(CXX) $(CPPFLAGS) $(CXXFLAGS) $(LDFLAGS) $(ICXXSRCS) $(SRCDIR_SRCS) $(SRCDIR_CXXSRCS) $(INCLUDES) \
	  $(GUILE_CFLAGS) $(GUILE_LIBS) $(LIBS) $(GUILE_LIBOPTS) -o $(TARGET)-guile

# -----------------------------------------------------------------
# Running a Guile example
# -----------------------------------------------------------------

guile_run:
	env GUILE_AUTO_COMPILE=0 $(RUNTOOL) $(GUILE) -l $(GUILE_SCRIPT) $(RUNPIPE)

guile_augmented_run:
	env GUILE_AUTO_COMPILE=0 $(RUNTOOL) ./$(TARGET) $(GUILE_RUNOPTIONS) -s $(GUILE_SCRIPT) $(RUNPIPE)

# -----------------------------------------------------------------
# Version display
# -----------------------------------------------------------------

guile_version:
	$(GUILE) --version | head -n 1

# -----------------------------------------------------------------
# Cleaning the Guile examples
# -----------------------------------------------------------------

guile_clean:
	rm -f *_wrap* *~ .~* my-guile $(TARGET)
	rm -f core 
	rm -f *.o *$(GUILE_SO)

##################################################################
#####                       JAVA                            ######
##################################################################

# You need to set this variable to the java directories containing the
# files "jni.h" and "md.h"
# usually something like /usr/java/include and /usr/java/include/<arch-osname>.
JAVA_INCLUDE= 

# Extra Java specific dynamic linking options
JAVA_DLNK  = 
JAVA_LIBPREFIX = lib
JAVASO =.so
JAVALDSHARED = $(LDSHARED)
JAVACXXSHARED = $(CXXSHARED)
JAVACFLAGS = 
JAVAFLAGS = 
JAVA = "java"
JAVAC =  -d .

# ----------------------------------------------------------------
# Build a java dynamically loadable module (C)
# ----------------------------------------------------------------

java: $(SRCDIR_SRCS)
	$(SWIG) -java $(SWIGOPT) -o $(ISRCS) $(INTERFACEPATH)
	$(CC) -c $(CCSHARED) $(CPPFLAGS) $(CFLAGS) $(JAVACFLAGS) $(SRCDIR_SRCS) $(ISRCS) $(INCLUDES) $(JAVA_INCLUDE)
	$(JAVALDSHARED) $(CFLAGS) $(LDFLAGS) $(OBJS) $(IOBJS) $(JAVA_DLNK) $(LIBS) -o $(JAVA_LIBPREFIX)$(TARGET)$(JAVASO)

# ----------------------------------------------------------------
# Build a java dynamically loadable module (C++)
# ----------------------------------------------------------------

java_cpp: $(SRCDIR_SRCS)
	$(SWIG) -java -c++ $(SWIGOPT) -o $(ICXXSRCS) $(INTERFACEPATH)
	$(CXX) -c $(CCSHARED) $(CPPFLAGS) $(CXXFLAGS) $(JAVACFLAGS) $(SRCDIR_SRCS) $(SRCDIR_CXXSRCS) $(ICXXSRCS) $(INCLUDES) $(JAVA_INCLUDE)
	$(JAVACXXSHARED) $(CXXFLAGS) $(LDFLAGS) $(OBJS) $(IOBJS) $(JAVA_DLNK) $(LIBS) $(CPP_DLLIBS) -o $(JAVA_LIBPREFIX)$(TARGET)$(JAVASO)

# ----------------------------------------------------------------
# Compile java files
# ----------------------------------------------------------------

java_compile: $(SRCDIR_SRCS)
	$(COMPILETOOL) $(JAVAC) $(addprefix $(SRCDIR),$(JAVASRCS))

# -----------------------------------------------------------------
# Run java example
# -----------------------------------------------------------------

java_run:
	env LD_LIBRARY_PATH=$$PWD $(RUNTOOL) $(JAVA) $(JAVAFLAGS) $(RUNME) $(RUNPIPE)

# -----------------------------------------------------------------
# Version display
# -----------------------------------------------------------------

java_version:
	$(JAVA) -version
	$(JAVAC) -version || echo "Unknown javac version"

# -----------------------------------------------------------------
# Cleaning the java examples
# -----------------------------------------------------------------

java_clean:
	rm -f *_wrap* *~ .~* *.class `find . -name \*.java | grep -v $(RUNME).java`
	rm -f core 
	rm -f *.o *.so

##################################################################
#####                       JAVASCRIPT                      ######
##################################################################

# Note: These targets are also from within Makefiles in the Example directories.
# There is a common makefile, 'Examples/javascript/js_example.mk' to simplify
# create a configuration for a new example.

ROOT_DIR = /home/tb246060/Documents/code/conda/conda2/conda-bld/work
JSINCLUDES =  
JSDYNAMICLINKING =  
NODEJS = 
NODEGYP = 

# ----------------------------------------------------------------
# Creating and building Javascript wrappers
# ----------------------------------------------------------------

javascript_wrapper:
	$(SWIG) -javascript $(SWIGOPT) -o $(INTERFACEDIR)$(TARGET)_wrap.c $(INTERFACEPATH)

javascript_wrapper_cpp: $(SRCDIR_SRCS)
	$(SWIG) -javascript -c++ $(SWIGOPT) -o $(INTERFACEDIR)$(TARGET)_wrap.cxx $(INTERFACEPATH)

javascript_build: $(SRCDIR_SRCS)
	$(CC) -c $(CCSHARED) $(CPPFLAGS) $(CFLAGS) $(ISRCS) $(SRCDIR_SRCS) $(INCLUDES) $(JSINCLUDES)
	$(LDSHARED) $(CFLAGS) $(LDFLAGS) $(OBJS) $(IOBJS) $(JSDYNAMICLINKING) $(LIBS) -o $(LIBPREFIX)$(TARGET)$(SO)

javascript_build_cpp: $(SRCDIR_SRCS)
ifeq (node,$(JSENGINE))
	sed -e 's|$$srcdir|./$(SRCDIR)|g' $(SRCDIR)binding.gyp.in > binding.gyp
	$(NODEGYP) --loglevel=silent configure build 1>>/dev/null
else
	$(CXX) -c $(CCSHARED) $(CPPFLAGS) $(CXXFLAGS) $(ICXXSRCS) $(SRCDIR_SRCS) $(SRCDIR_CXXSRCS) $(INCLUDES) $(JSINCLUDES)
	$(CXXSHARED) $(CXXFLAGS) $(LDFLAGS) $(OBJS) $(IOBJS) $(JSDYNAMICLINKING) $(LIBS) $(CPP_DLLIBS) -o $(LIBPREFIX)$(TARGET)$(SO)

endif

# These targets are used by the test-suite:

javascript: $(SRCDIR_SRCS) javascript_custom_interpreter
	$(SWIG) -javascript $(SWIGOPT) $(INTERFACEPATH)
ifeq (jsc, $(ENGINE))
	$(CC) -c $(CCSHARED) $(CPPFLAGS) $(CFLAGS) $(ISRCS) $(SRCDIR_SRCS) $(INCLUDES) $(JSINCLUDES)
	$(LDSHARED) $(CFLAGS) $(LDFLAGS) $(OBJS) $(IOBJS) $(JSDYNAMICLINKING) $(LIBS) -o $(LIBPREFIX)$(TARGET)$(SO)
else # (v8 | node) # v8 and node must be compiled as c++
	$(CXX) -c $(CCSHARED) $(CPPFLAGS) $(CXXFLAGS) $(ISRCS) $(SRCDIR_SRCS) $(SRCDIR_CXXSRCS) $(INCLUDES) $(JSINCLUDES)
	$(CXXSHARED) $(CXXFLAGS) $(LDFLAGS) $(OBJS) $(IOBJS) $(JSDYNAMICLINKING) $(LIBS) $(CPP_DLLIBS) -o $(LIBPREFIX)$(TARGET)$(SO)
endif

javascript_cpp: $(SRCDIR_SRCS) javascript_custom_interpreter
	$(SWIG) -javascript -c++ $(SWIGOPT) $(INTERFACEPATH)
	$(CXX) -c $(CCSHARED) $(CPPFLAGS) $(CXXFLAGS) $(ICXXSRCS) $(SRCDIR_SRCS) $(SRCDIR_CXXSRCS) $(INCLUDES) $(JSINCLUDES)
	$(CXXSHARED) $(CXXFLAGS) $(LDFLAGS) $(OBJS) $(IOBJS) $(JSDYNAMICLINKING) $(LIBS) $(CPP_DLLIBS) -o $(LIBPREFIX)$(TARGET)$(SO)

# -----------------------------------------------------------------
# Running a Javascript example
# -----------------------------------------------------------------

javascript_custom_interpreter:
	(cd $(ROOT_DIR)/Tools/javascript && $(MAKE) JSENGINE='$(JSENGINE)')

ifeq (node,$(JSENGINE))
javascript_run:
	env NODE_PATH=$$PWD:$(SRCDIR) $(RUNTOOL) $(NODEJS) $(SRCDIR)$(RUNME).js $(RUNPIPE)
else
javascript_run: javascript_custom_interpreter
	$(RUNTOOL) $(ROOT_DIR)/Tools/javascript/javascript -$(JSENGINE) -L $(TARGET) $(SRCDIR)$(RUNME).js $(RUNPIPE)
endif

# -----------------------------------------------------------------
# Version display
# -----------------------------------------------------------------

javascript_version:
ifeq (, $(ENGINE))
	@if [ "$(NODEJS)" != "" ]; then \
	  echo "Node.js: `($(NODEJS) --version)`"; \
	  echo "node-gyp: `($(NODEGYP) --version)`"; \
	else \
	  echo "Version depends on the interpreter"; \
	fi
endif
ifeq (node, $(ENGINE))
	echo "Node.js: `($(NODEJS) --version)`"
	echo "node-gyp: `($(NODEGYP) --version)`"
endif
ifeq (jsc, $(ENGINE))
	@if [ "" != "" ]; then \
	  echo ""; \
	else \
	  echo "Unknown JavascriptCore version."; \
	fi
endif
ifeq (v8, $(ENGINE))
	echo "Unknown v8 version."
endif

# -----------------------------------------------------------------
# Cleaning the Javascript examples
# -----------------------------------------------------------------

javascript_clean:
	rm -rf build
	rm -f *_wrap* $(RUNME)
	rm -f core 
	rm -f *.o *.so
	rm -f binding.gyp example-gypcopy.cxx
	cd $(ROOT_DIR)/Tools/javascript && $(MAKE) -s clean

##################################################################
#####                       ANDROID                         ######
##################################################################

ANDROID = 
ANDROID_NDK_BUILD = 
ANDROID_ADB = 
ANT = ant
TARGETID = 1

# ----------------------------------------------------------------
# Build an Android dynamically loadable module (C)
# ----------------------------------------------------------------

android: $(SRCDIR_SRCS)
	$(ANDROID) $(SILENT_OPTION) update project --target $(TARGETID) --name $(PROJECTNAME) --path .
	$(SWIG) -java $(SWIGOPT) -o $(INTERFACEDIR)$(TARGET)_wrap.c $(INTERFACEPATH)
	+$(ANDROID_NDK_BUILD) $(SILENT_PIPE)
	$(ANT) $(ANT_QUIET) debug

# ----------------------------------------------------------------
# Build an Android dynamically loadable module (C++)
# ----------------------------------------------------------------

android_cpp: $(SRCDIR_SRCS)
	$(ANDROID) $(SILENT_OPTION) update project --target $(TARGETID) --name $(PROJECTNAME) --path .
	$(SWIG) -java -c++ $(SWIGOPT) -o $(INTERFACEDIR)$(TARGET)_wrap.cpp $(INTERFACEPATH)
	+$(ANDROID_NDK_BUILD) $(SILENT_PIPE)
	$(ANT) $(ANT_QUIET) debug

# ----------------------------------------------------------------
# Android install
# ----------------------------------------------------------------

android_install:
	-$(ANDROID_ADB) uninstall $(PACKAGENAME)
	$(ANDROID_ADB) install $(INSTALLOPTIONS) bin/$(PROJECTNAME)-debug.apk

# -----------------------------------------------------------------
# Version display
# -----------------------------------------------------------------

android_version:
	$(ANDROID_ADB) version

# -----------------------------------------------------------------
# Cleaning the Android examples
# -----------------------------------------------------------------

android_clean:
	test -n "$(SRCDIR)" && cd $(SRCDIR) ; $(ANT) -q -logfile /dev/null clean
	rm -f $(INTERFACEDIR)$(TARGET)_wrap.*
	rm -f `find $(PACKAGEDIR) -name \*.java | grep -v $(PROJECTNAME).java`
	rm -rf obj

##################################################################
#####                      MODULA3                          ######
##################################################################

MODULA3_INCLUDE= @MODULA3INC@

# ----------------------------------------------------------------
# Build a modula3 dynamically loadable module (C)
# ----------------------------------------------------------------

modula3: $(SRCDIR_SRCS)
	$(SWIG) -modula3 $(SWIGOPT) -o $(ISRCS) $(INTERFACEPATH)

modula3_cpp: $(SRCDIR_SRCS)
	$(SWIG) -modula3 -c++ $(SWIGOPT) -o $(ICXXSRCS) $(INTERFACEPATH)

# -----------------------------------------------------------------
# Run modula3 example
# -----------------------------------------------------------------

modula3_run:
	$(RUNTOOL) false $(RUNPIPE)

# -----------------------------------------------------------------
# Version display
# -----------------------------------------------------------------

modula3_version:
	echo "Unknown modula3 version"

# -----------------------------------------------------------------
# Cleaning the modula3 examples
# -----------------------------------------------------------------

modula3_clean:
	rm -f *_wrap* *.i3 *.m3
	rm -f core 
	rm -f *.o *.so

##################################################################
#####                       MZSCHEME                        ######
##################################################################

MZSCHEME = mzscheme
MZC = 
MZDYNOBJ = 
MZSCHEME_SO = .so
MZSCHEME_SCRIPT = $(RUNME).scm

# ----------------------------------------------------------------
# Build a C/C++ dynamically loadable module
# ----------------------------------------------------------------

mzscheme: $(SRCDIR_SRCS)
	$(SWIG) -mzscheme $(SWIGOPT) -o $(ISRCS) $(INTERFACEPATH)
	$(COMPILETOOL) $(MZC) `echo $(INCLUDES) | sed 's/-I/++ccf -I/g'` --cc $(ISRCS) $(SRCDIR_SRCS)
	$(COMPILETOOL) $(MZC) --ld $(TARGET)$(MZSCHEME_SO) $(OBJS) $(IOBJS)

mzscheme_cpp: $(SRCDIR_SRCS)
	$(SWIG) -mzscheme -c++ $(SWIGOPT) -o $(ICXXSRCS) $(INTERFACEPATH)
	$(COMPILETOOL) $(MZC) `echo $(INCLUDES) | sed 's/-I/++ccf -I/g'` --cc $(ICXXSRCS) $(SRCDIR_SRCS) $(SRCDIR_CXXSRCS)
	$(CXXSHARED) $(CPPFLAGS) $(CXXFLAGS) $(LDFLAGS) -o $(LIBPREFIX)$(TARGET)$(MZSCHEME_SO) $(OBJS) $(IOBJS) $(MZDYNOBJ) $(CPP_DLLIBS)

# -----------------------------------------------------------------
# Run mzscheme example
# -----------------------------------------------------------------

mzscheme_run:
	env LD_LIBRARY_PATH=$$PWD $(RUNTOOL) $(MZSCHEME) -r $(MZSCHEME_SCRIPT) $(RUNPIPE)

# -----------------------------------------------------------------
# Version display
# -----------------------------------------------------------------

mzscheme_version:
	$(MZSCHEME) -v
	$(MZC) -v

# -----------------------------------------------------------------
# Cleaning the mzscheme examples
# -----------------------------------------------------------------

mzscheme_clean:
	rm -f *_wrap* *~ .~*
	rm -f core 
	rm -f *.o *$(MZSCHEME_SO)

##################################################################
#####                          Ocaml                         #####
##################################################################

OCC=
OCAMLDLGEN=
OCAMLFIND=
OCAMLMKTOP= $(SWIGWHERE)
NOLINK ?= false
OCAMLPP= -pp "camlp4o ./swigp4.cmo"
OCAMLP4WHERE=`$(COMPILETOOL)  -where`
OCAMLCORE=\
	rm -rf swig.mli swig.ml swigp4.ml && \
	$(SWIG) -ocaml -co swig.mli 2>/dev/null &&  \
	$(SWIG) -ocaml -co swig.ml 2>/dev/null &&  \
	$(SWIG) -ocaml -co swigp4.ml 2>/dev/null &&  \
	$(OCC) -c swig.mli &&  \
	$(OCC) -c swig.ml &&  \
	$(OCC) -I $(OCAMLP4WHERE) -pp "camlp4o pa_extend.cmo q_MLast.cmo" \
		-c swigp4.ml

ocaml_static: $(SRCDIR_SRCS)
	$(OCAMLCORE)
	$(SWIG) -ocaml $(SWIGOPT) -o $(ISRCS) $(INTERFACEPATH)
	$(OCC) -g -c -ccopt -g -ccopt "$(INCLUDES)" $(ISRCS) $(SRCDIR_SRCS)
	$(OCC) -g -c $(INTERFACE:%.i=%.mli)
	$(OCC) -g -c $(INTERFACE:%.i=%.ml)
	test -z "$(PROGFILE)" || test -f "$(PROGFILE)" && \
		$(OCC) $(OCAMLPP) -c $(PROGFILE)
	$(NOLINK) || $(OCC) -g -ccopt -g -cclib -g -custom -o $(TARGET) \
		swig.cmo \
		$(INTERFACE:%.i=%.cmo) \
		$(PROGFILE:%.ml=%.cmo) \
		$(INTERFACE:%.i=%_wrap.o) $(OBJS) -cclib "$(LIBS)"

ocaml_dynamic: $(SRCDIR_SRCS)
	$(OCAMLCORE)
	$(SWIG) -ocaml $(SWIGOPT) -o $(ISRCS) $(INTERFACEPATH)
	$(OCC) -g -c -ccopt -g -ccopt "$(INCLUDES)" $(ISRCS) $(SRCDIR_SRCS)
	$(CXXSHARED) $(CPPFLAGS) $(CXXFLAGS) $(LDFLAGS) $(CCSHARED) -o $(INTERFACE:%.i=%.so) \
		$(INTERFACE:%.i=%_wrap.o) $(OBJS) $(LIBS)
	$(OCAMLDLGEN) $(INTERFACE:%.i=%.ml) $(INTERFACE:%.i=%.so) > \
		$(INTERFACE:%.i=%_dynamic.ml)
	mv $(INTERFACE:%.i=%_dynamic.ml) $(INTERFACE:%.i=%.ml)
	rm $(INTERFACE:%.i=%.mli)
	$(OCAMLFIND) $(OCC) -g -c -package dl $(INTERFACE:%.i=%.ml)
	test -z "$(PROGFILE)" || test -f "$(PROGFILE)" && \
		$(OCC) $(OCAMLPP) -c $(PROGFILE)
	$(NOLINK) || $(OCAMLFIND) \
		$(OCC) -g -ccopt -g -cclib -g -custom -o $(TARGET) \
		swig.cmo \
		-package dl -linkpkg \
		$(INTERFACE:%.i=%.cmo) $(PROGFILE:%.ml=%.cmo)

ocaml_static_toplevel: $(SRCDIR_SRCS)
	$(OCAMLCORE)
	$(SWIG) -ocaml $(SWIGOPT) -o $(ISRCS) $(INTERFACEPATH)
	$(OCC) -g -c -ccopt -g -ccopt "$(INCLUDES)" $(ISRCS) $(SRCDIR_SRCS)
	$(OCC) -g -c $(INTERFACE:%.i=%.mli)
	$(OCC) -g -c $(INTERFACE:%.i=%.ml)
	test -z "$(PROGFILE)" || test -f "$(PROGFILE)" && \
		$(OCC) $(OCAMLPP) -c $(PROGFILE)
	$(NOLINK) || $(OCAMLMKTOP) \
		swig.cmo \
		-I $(OCAMLP4WHERE) camlp4o.cma swigp4.cmo \
		-g -ccopt -g -cclib -g -custom -o $(TARGET)_top \
		$(INTERFACE:%.i=%.cmo) \
		$(INTERFACE:%.i=%_wrap.o) $(OBJS) -cclib "$(LIBS)"

ocaml_static_cpp: $(SRCDIR_SRCS)
	$(OCAMLCORE)
	$(SWIG) -ocaml -c++ $(SWIGOPT) -o $(ICXXSRCS) $(INTERFACEPATH)
	cp $(ICXXSRCS) $(ICXXSRCS:%.cxx=%.c)
	$(OCC) -cc '$(CXX) -Wno-write-strings' -g -c -ccopt -g -ccopt "-xc++ $(INCLUDES)" \
		$(ICXXSRCS:%.cxx=%.c) $(SRCDIR_SRCS) $(SRCDIR_CXXSRCS)
	$(OCC) -g -c $(INTERFACE:%.i=%.mli)
	$(OCC) -g -c $(INTERFACE:%.i=%.ml)
	test -z "$(PROGFILE)" || test -f "$(PROGFILE)" && \
		$(OCC) $(OCAMLPP) -c $(PROGFILE)
	$(NOLINK) || $(OCC) -g -ccopt -g -cclib -g -custom -o $(TARGET) \
		swig.cmo \
		$(INTERFACE:%.i=%.cmo) \
		$(PROGFILE:%.ml=%.cmo) \
		$(INTERFACE:%.i=%_wrap.o) $(OBJS) \
		-cclib "$(LIBS)" -cc '$(CXX) -Wno-write-strings'

ocaml_static_cpp_toplevel: $(SRCDIR_SRCS)
	$(OCAMLCORE)
	$(SWIG) -ocaml -c++ $(SWIGOPT) -o $(ICXXSRCS) $(INTERFACEPATH)
	cp $(ICXXSRCS) $(ICXXSRCS:%.cxx=%.c)
	$(OCC) -cc '$(CXX) -Wno-write-strings' -g -c -ccopt -g -ccopt "-xc++ $(INCLUDES)" \
		$(ICXXSRCS:%.cxx=%.c) $(SRCDIR_SRCS) $(SRCDIR_CXXSRCS)
	$(OCC) -g -c $(INTERFACE:%.i=%.mli)
	$(OCC) -g -c $(INTERFACE:%.i=%.ml)
	test -z "$(PROGFILE)" || test -f "$(PROGFILE)" && \
		$(OCC) $(OCAMLPP) -c $(PROGFILE)
	$(NOLINK) || $(OCAMLMKTOP) \
		swig.cmo \
		-I $(OCAMLP4WHERE) dynlink.cma camlp4o.cma swigp4.cmo \
		-g -ccopt -g -cclib -g -custom -o $(TARGET)_top \
		$(INTERFACE:%.i=%.cmo) \
		$(INTERFACE:%.i=%_wrap.o) $(OBJS) \
		-cclib "$(LIBS)" -cc '$(CXX) -Wno-write-strings'

ocaml_dynamic_cpp: $(SRCDIR_SRCS)
	$(OCAMLCORE)
	$(SWIG) -ocaml -c++ $(SWIGOPT) -o $(ICXXSRCS) $(INTERFACEPATH)
	cp $(ICXXSRCS) $(ICXXSRCS:%.cxx=%.c)
	$(OCC) -cc '$(CXX) -Wno-write-strings' -g -c -ccopt -g -ccopt "-xc++ $(INCLUDES)" \
		$(ICXXSRCS:%.cxx=%.c) $(SRCDIR_SRCS) $(SRCDIR_CXXSRCS) -ccopt -fPIC
	$(CXXSHARED) $(CPPFLAGS) $(CXXFLAGS) $(LDFLAGS) -o $(INTERFACE:%.i=%.so) \
		$(INTERFACE:%.i=%_wrap.o) $(OBJS) \
		$(CPP_DLLIBS) $(LIBS)
	$(OCAMLDLGEN) $(INTERFACE:%.i=%.ml) $(INTERFACE:%.i=%.so) > \
		$(INTERFACE:%.i=%_dynamic.ml)
	mv $(INTERFACE:%.i=%_dynamic.ml) $(INTERFACE:%.i=%.ml)
	rm $(INTERFACE:%.i=%.mli)
	$(OCAMLFIND) $(OCC) -g -c -package dl $(INTERFACE:%.i=%.ml)
	test -z "$(PROGFILE)" || test -f "$(PROGFILE)" && \
		$(OCC) $(OCAMLPP) -c $(PROGFILE)
	$(NOLINK) || $(OCAMLFIND) \
		swig.cmo \
		$(OCC) -cclib -export-dynamic -g -ccopt -g -cclib -g -custom \
		-o $(TARGET) \
		-package dl -linkpkg \
		$(INTERFACE:%.i=%.cmo) $(PROGFILE:%.ml=%.cmo) -cc '$(CXX) -Wno-write-strings'

# -----------------------------------------------------------------
# Run ocaml example
# -----------------------------------------------------------------

ocaml_run:
	$(RUNTOOL) ./$(TARGET) $(RUNPIPE)

# -----------------------------------------------------------------
# Version display
# -----------------------------------------------------------------

ocaml_version:
	$(OCC) -version

# -----------------------------------------------------------------
# Cleaning the Ocaml examples
# -----------------------------------------------------------------

ocaml_clean:
	rm -f *_wrap* *~ .~* *.cmo *.cmi $(MLFILE) $(MLFILE)i swig.mli swig.cmi swig.ml swig.cmo swigp4.ml swigp4.cmo
	rm -f core 
	rm -f *.o *.so

##################################################################
#####                       RUBY                            ######
##################################################################

# Make sure these locate your Ruby installation
RUBY_CFLAGS=  $(DEFS)
RUBY_INCLUDE= 
RUBY_LIB     = 
RUBY_DLNK = 
RUBY_LIBOPTS =  -ldl  -L/home/tb246060/Documents/code/conda/conda2/envs/_build_placehold_placehold_place/lib -lpcre $(SYSLIBS)
RUBY_SO = .so
RUBY = 
RUBY_SCRIPT = $(SRCDIR)$(RUNME).rb


# ----------------------------------------------------------------
# Build a C dynamically loadable module
# ----------------------------------------------------------------

ruby: $(SRCDIR_SRCS)
	$(SWIG) -ruby $(SWIGOPT) -o $(ISRCS) $(INTERFACEPATH)
	$(CC) -c $(CCSHARED) $(CPPFLAGS) $(CFLAGS) $(RUBY_CFLAGS) $(ISRCS) $(SRCDIR_SRCS) $(INCLUDES) $(RUBY_INCLUDE)
	$(LDSHARED) $(CFLAGS) $(LDFLAGS) $(OBJS) $(IOBJS) $(RUBY_DLNK) $(LIBS) -o $(LIBPREFIX)$(TARGET)$(RUBY_SO)

# -----------------------------------------------------------------
# Build a C++ dynamically loadable module
# -----------------------------------------------------------------

ruby_cpp: $(SRCDIR_SRCS)
	$(SWIG) -c++ -ruby $(SWIGOPT) -o $(ICXXSRCS) $(INTERFACEPATH)
	$(CXX) -c $(CCSHARED) $(CPPFLAGS) $(CXXFLAGS) $(RUBY_CFLAGS) $(ICXXSRCS) $(SRCDIR_SRCS) $(SRCDIR_CXXSRCS) $(INCLUDES) $(RUBY_INCLUDE)
	$(CXXSHARED) $(CXXFLAGS) $(LDFLAGS) $(OBJS) $(IOBJS) $(RUBY_DLNK) $(LIBS) $(CPP_DLLIBS) -o $(LIBPREFIX)$(TARGET)$(RUBY_SO)

# -----------------------------------------------------------------
# Build statically linked Ruby interpreter
#
# These should only be used in conjunction with the %include embed.i
# library file
# -----------------------------------------------------------------

ruby_static: $(SRCDIR_SRCS)
	$(SWIG) -ruby -lembed.i $(SWIGOPT) -o $(ISRCS) $(INTERFACEPATH)
	$(CC) $(CPPFLAGS) $(CFLAGS) $(LDFLAGS) $(RUBY_CFLAGS) -Xlinker -export-dynamic $(ISRCS) $(SRCDIR_SRCS) $(INCLUDES) \
	$(RUBY_INCLUDE) $(LIBS) -L$(RUBY_LIB) $(RUBY_LIBOPTS) -o $(TARGET)

ruby_cpp_static: $(SRCDIR_SRCS)
	$(SWIG) -c++ -ruby -lembed.i $(SWIGOPT) -o $(ICXXSRCS) $(INTERFACEPATH)
	$(CXX) $(CPPFLAGS) $(CXXFLAGS) $(LDFLAGS) $(RUBY_CFLAGS) $(ICXXSRCS) $(SRCDIR_SRCS) $(SRCDIR_CXXSRCS) $(INCLUDES) \
	$(RUBY_INCLUDE) $(LIBS)  -L$(RUBY_LIB) $(RUBY_LIBOPTS) -o $(TARGET)

# -----------------------------------------------------------------
# Run Ruby example
# -----------------------------------------------------------------

ruby_run:
	$(RUNTOOL) $(RUBY) $(RUBYFLAGS) -I. $(RUBY_SCRIPT) $(RUNPIPE)

# -----------------------------------------------------------------
# Version display
# -----------------------------------------------------------------

ruby_version:
	$(RUBY) -v

# -----------------------------------------------------------------
# Cleaning the Ruby examples
# -----------------------------------------------------------------

ruby_clean:
	rm -f *_wrap* *~ .~* myruby
	rm -f core 
	rm -f *.o *$(RUBY_SO)

##################################################################
#####                       PHP                             ######
##################################################################

PHP         = 
PHP_INCLUDE = 
PHP_SO      = .so
PHP_SCRIPT  = $(SRCDIR)$(RUNME).php

# -------------------------------------------------------------------
# Build a PHP dynamically loadable module (C)
# -------------------------------------------------------------------

php: $(SRCDIR_SRCS)
	$(SWIG) -php $(SWIGOPT) -o $(ISRCS) $(INTERFACEPATH)
	$(CC) -c $(CCSHARED) $(CPPFLAGS) $(CFLAGS) $(SRCDIR_SRCS) $(ISRCS) $(INCLUDES) $(PHP_INCLUDE)
	$(LDSHARED) $(CFLAGS) $(LDFLAGS) $(OBJS) $(IOBJS) $(LIBS) -o $(LIBPREFIX)$(TARGET)$(PHP_SO)

# --------------------------------------------------------------------
# Build a PHP dynamically loadable module (C++)
# --------------------------------------------------------------------

php_cpp: $(SRCDIR_SRCS)
	$(SWIG) -php -cppext cxx -c++ $(SWIGOPT) -o $(ICXXSRCS) $(INTERFACEPATH)
	$(CXX) -c $(CCSHARED) $(CPPFLAGS) $(CXXFLAGS) $(SRCDIR_SRCS) $(SRCDIR_CXXSRCS) $(ICXXSRCS) $(INCLUDES) $(PHP_INCLUDE)
	$(CXXSHARED) $(CXXFLAGS) $(LDFLAGS) $(OBJS) $(IOBJS) $(LIBS) $(CPP_DLLIBS) -o $(LIBPREFIX)$(TARGET)$(PHP_SO)

# -----------------------------------------------------------------
# Running a PHP example
# -----------------------------------------------------------------

php_run:
	$(RUNTOOL) $(PHP) -n -q -d extension_dir=. -d safe_mode=Off $(PHP_SCRIPT) $(RUNPIPE)

# -----------------------------------------------------------------
# Version display
# -----------------------------------------------------------------

php_version:
	$(PHP) -v | head -n 1

# -----------------------------------------------------------------
# Cleaning the PHP examples
# -----------------------------------------------------------------

php_clean:
	rm -f *_wrap* *~ .~* example.php php_example.h
	rm -f core 
	rm -f *.o *$(PHP_SO)

##################################################################
#####                       Pike                            ######
##################################################################

# Make sure these locate your Pike installation
PIKE         = pike
PIKE_CFLAGS  =  -DHAVE_CONFIG_H
PIKE_INCLUDE = 
PIKE_LIB     = @PIKELIB@
PIKE_DLNK    = 
PIKE_LIBOPTS = @PIKELINK@ -ldl  -L/home/tb246060/Documents/code/conda/conda2/envs/_build_placehold_placehold_place/lib -lpcre $(SYSLIBS)
PIKE_SCRIPT  = $(RUNME).pike

# ----------------------------------------------------------------
# Build a C dynamically loadable module
# ----------------------------------------------------------------

pike: $(SRCDIR_SRCS)
	$(SWIG) -pike $(SWIGOPT) -o $(ISRCS) $(INTERFACEPATH)
	$(CC) -c $(CCSHARED) $(CPPFLAGS) $(CFLAGS) $(PIKE_CFLAGS) $(ISRCS) $(SRCDIR_SRCS) $(INCLUDES) $(PIKE_INCLUDE)
	$(LDSHARED) $(CFLAGS) $(LDFLAGS) $(OBJS) $(IOBJS) $(PIKE_DLNK) $(LIBS) -o $(LIBPREFIX)$(TARGET)$(SO)

# -----------------------------------------------------------------
# Build a C++ dynamically loadable module
# -----------------------------------------------------------------

pike_cpp: $(SRCDIR_SRCS)
	$(SWIG) -c++ -pike $(SWIGOPT) -o $(ICXXSRCS) $(INTERFACEPATH)
	$(CXX) -c $(CCSHARED) $(CPPFLAGS) $(CXXFLAGS) $(PIKE_CFLAGS) $(ICXXSRCS) $(SRCDIR_SRCS) $(SRCDIR_CXXSRCS) $(INCLUDES) $(PIKE_INCLUDE)
	$(CXXSHARED) $(CXXFLAGS) $(LDFLAGS) $(OBJS) $(IOBJS) $(PIKE_DLNK) $(LIBS) $(CPP_DLLIBS) -o $(LIBPREFIX)$(TARGET)$(SO)

# -----------------------------------------------------------------
# Build statically linked Pike interpreter
#
# These should only be used in conjunction with the %include embed.i
# library file
# -----------------------------------------------------------------

pike_static: $(SRCDIR_SRCS)
	$(SWIG) -pike -lembed.i $(SWIGOPT) -o $(ISRCS) $(INTERFACEPATH)
	$(CC) $(CPPFLAGS) $(CFLAGS) $(LDFLAGS) $(PIKE_CFLAGS) -Xlinker -export-dynamic $(ISRCS) $(SRCDIR_SRCS) $(INCLUDES) \
	$(PIKE_INCLUDE) $(LIBS) -L$(PIKE_LIB) $(PIKE_LIBOPTS) -o $(TARGET)

pike_cpp_static: $(SRCDIR_SRCS)
	$(SWIG) -c++ -pike -lembed.i $(SWIGOPT) -o $(ICXXSRCS) $(INTERFACEPATH)
	$(CXX) $(CPPFLAGS) $(CXXFLAGS) $(LDFLAGS) $(PIKE_CFLAGS) $(ICXXSRCS) $(SRCDIR_SRCS) $(SRCDIR_CXXSRCS) $(INCLUDES) \
	$(PIKE_INCLUDE) $(LIBS)  -L$(PIKE_LIB) $(PIKE_LIBOPTS) -o $(TARGET)

# -----------------------------------------------------------------
# Run pike example
# -----------------------------------------------------------------

pike_run:
	$(RUNTOOL) $(PIKE) $(PIKE_SCRIPT) $(RUNPIPE)

# -----------------------------------------------------------------
# Version display
# -----------------------------------------------------------------

pike_version:
	$(PIKE) -v 2>&1 | head -n 1

# -----------------------------------------------------------------
# Cleaning the Pike examples
# -----------------------------------------------------------------

pike_clean:
	rm -f *_wrap* *~ .~* mypike
	rm -f core 
	rm -f *.o *.so


##################################################################
#####                      Chicken                          ######
##################################################################

CHICKEN = 
CHICKEN_CSC = 
CHICKEN_CSI = 
CHICKEN_LIBOPTS =   $(SYSLIBS)
CHICKEN_SHAREDLIBOPTS =   $(SYSLIBS)
CHICKEN_CFLAGS = 
CHICKENOPTS = -quiet
CHICKEN_MAIN =
CHICKEN_SCRIPT = $(RUNME).scm

# SWIG produces $(ISRCS) (the C wrapper file)
# and $(CHICKEN_GENERATED_SCHEME) (the Scheme wrapper file):
CHICKEN_GENERATED_SCHEME = $(INTERFACE:.i=.scm)
CHICKEN_COMPILED_SCHEME = $(INTERFACE:.i=_chicken.c)
CHICKEN_COMPILED_OBJECT = $(CHICKEN_COMPILED_SCHEME:.c=.o)

# flags for the main chicken sources (only used when compiling statically)
CHICKEN_COMPILED_MAIN = $(CHICKEN_MAIN:.scm=_chicken.c)
CHICKEN_COMPILED_MAIN_OBJECT = $(CHICKEN_COMPILED_MAIN:.c=.o)

# -----------------------------------------------------------------
# Build a CHICKEN dynamically loadable module
# -----------------------------------------------------------------

# This is the old way to build chicken, but it does not work correctly with exceptions
chicken_direct: $(SRCDIR_SRCS)
	$(SWIG) -chicken $(SWIGOPT) $(INCLUDE) $(INTERFACEPATH)
	$(CHICKEN) $(CHICKEN_GENERATED_SCHEME) $(CHICKENOPTS) \
		-dynamic -feature chicken-compile-shared \
		-output-file $(CHICKEN_COMPILED_SCHEME)
	$(CC) -c $(CCSHARED) $(CPPFLAGS) $(CFLAGS) $(CHICKEN_CFLAGS) \
		$(INCLUDES) $(CHICKEN_INCLUDE) $(ISRCS) $(SRCDIR_SRCS) $(CHICKEN_COMPILED_SCHEME)
	$(LDSHARED) $(CFLAGS) $(LDFLAGS) $(CHICKEN_COMPILED_OBJECT) $(OBJS) $(IOBJS) \
		$(LIBS) $(CHICKEN_SHAREDLIBOPTS) -o $(LIBPREFIX)$(TARGET)$(SO)

chicken_direct_cpp: $(SRCDIR_CXXSRCS) $(CHICKSRCS)
	$(SWIG) -c++ -chicken $(SWIGOPT) $(INCLUDE) $(INTERFACEPATH)
	$(CHICKEN) $(CHICKEN_GENERATED_SCHEME) $(CHICKENOPTS) \
		-dynamic -feature chicken-compile-shared \
		-output-file $(CHICKEN_COMPILED_SCHEME)
	$(CXX) -c $(CCSHARED) $(CPPFLAGS) $(CXXFLAGS) $(CHICKEN_CFLAGS) \
		$(INCLUDES) $(CHICKEN_INCLUDE) $(ICXXSRCS) $(SRCDIR_SRCS) $(SRCDIR_CXXSRCS) $(CHICKEN_COMPILED_SCHEME)
	$(CXXSHARED) $(CXXFLAGS) $(LDFLAGS) $(CHICKEN_COMPILED_OBJECT) $(OBJS) $(IOBJS) \
		$(LIBS) $(CPP_DLLIBS) $(CHICKEN_SHAREDLIBOPTS) -o $(LIBPREFIX)$(TARGET)$(SO)

# -----------------------------------------------------------------
# Build statically linked CHICKEN interpreter
# -----------------------------------------------------------------

# The following two targets are also used by the test suite
chicken_static: $(SRCDIR_SRCS) $(CHICKSRCS)
	$(SWIG) -chicken $(SWIGOPT) $(INCLUDE) $(INTERFACEPATH)
	$(CHICKEN) $(CHICKEN_GENERATED_SCHEME) $(CHICKENOPTS) \
		-output-file $(CHICKEN_COMPILED_SCHEME)
	$(CHICKEN) $(CHICKEN_MAIN) $(CHICKENOPTS) \
		-output-file $(CHICKEN_MAIN:.scm=_chicken.c)
	$(CC) -c $(CCSHARED) $(CPPFLAGS) $(CFLAGS) $(CHICKEN_CFLAGS) \
		$(INCLUDES) $(CHICKEN_INCLUDE) $(ISRCS) $(SRCDIR_SRCS) \
		$(CHICKEN_COMPILED_SCHEME) $(CHICKEN_COMPILED_MAIN)
	$(CC) $(CFLAGS) $(LDFLAGS) $(CHICKEN_COMPILED_OBJECT) $(CHICKEN_COMPILED_MAIN_OBJECT) \
		$(OBJS) $(IOBJS) $(LIBS) $(CHICKEN_SHAREDLIBOPTS) -o $(TARGET)

chicken_static_cpp: $(SRCDIR_CXXSRCS) $(CHICKSRCS)
	$(SWIG) -c++ -chicken $(SWIGOPT) $(INCLUDE) $(INTERFACEPATH)
	$(CHICKEN) $(CHICKEN_GENERATED_SCHEME) $(CHICKENOPTS) \
		-output-file $(CHICKEN_COMPILED_SCHEME)
	$(CHICKEN) $(CHICKEN_MAIN) $(CHICKENOPTS) \
		-output-file $(CHICKEN_MAIN:.scm=_chicken.c)
	$(CXX) -c $(CCSHARED) $(CPPFLAGS) $(CXXFLAGS) $(CHICKEN_CFLAGS) \
		$(INCLUDES) $(CHICKEN_INCLUDE) $(ICXXSRCS) $(SRCDIR_SRCS) $(SRCDIR_CXXSRCS) \
		$(CHICKEN_COMPILED_SCHEME) $(CHICKEN_COMPILED_MAIN)
	$(CXX) $(CXXFLAGS) $(LDFLAGS) $(CHICKEN_COMPILED_OBJECT) $(CHICKEN_COMPILED_MAIN_OBJECT) \
		$(OBJS) $(IOBJS) $(LIBS) $(CPP_DLLIBS) $(CHICKEN_SHAREDLIBOPTS) -o $(TARGET)

# ----------------------------------------------------------------
# Build a shared library using csc
# ----------------------------------------------------------------

chicken:
	$(SWIG) -chicken $(SWIGOPT) $(INCLUDE) $(INTERFACEPATH)
	$(COMPILETOOL) $(CHICKEN_CSC) -s `echo $(INCLUDES) | sed 's/-I/-C -I/g'` $(CHICKEN_GENERATED_SCHEME) $(SRCDIR_SRCS) $(ISRCS) -o $(TARGET)$(SO)

chicken_cpp:
	$(SWIG) -c++ -chicken $(SWIGOPT) $(INCLUDE) $(INTERFACEPATH)
	$(COMPILETOOL) $(CHICKEN_CSC) -s `echo $(INCLUDES) | sed 's/-I/-C -I/g'` $(CHICKEN_GENERATED_SCHEME) $(SRCDIR_SRCS) $(ICXXSRCS) $(SRCDIR_CXXSRCS) -o $(TARGET)$(SO)

chicken_externalhdr:
	$(SWIG) -chicken -external-runtime $(TARGET)

# -----------------------------------------------------------------
# Run CHICKEN example
# -----------------------------------------------------------------

chicken_run:
	env LD_LIBRARY_PATH=$$PWD $(RUNTOOL) $(CHICKEN_CSI) $(CHICKEN_SCRIPT) $(RUNPIPE)

# -----------------------------------------------------------------
# Version display
# -----------------------------------------------------------------

chicken_version:
	$(CHICKEN) -version | grep -i version

# -----------------------------------------------------------------
# Cleaning the CHICKEN examples
# -----------------------------------------------------------------

chicken_clean:
	rm -f *_wrap* *~ .~* *_chicken*
	rm -f core 
	rm -f *.o *.so

##################################################################
#####                      CSHARP                           ######
##################################################################

# Extra CSharp specific dynamic linking options
CSHARP_DLNK  = 
CSHARP_LIBPREFIX = lib
CSHARPCOMPILER = 
CSHARPCILINTERPRETER = 
CSHARPCILINTERPRETER_FLAGS = 
CSHARPCFLAGS = 
CSHARPFLAGS =
CSHARPOPTIONS =
CSHARPSO = .so
CSHARP_RUNME = $(CSHARPCILINTERPRETER) $(CSHARPCILINTERPRETER_FLAGS) ./$(RUNME).exe

# ----------------------------------------------------------------
# Build a CSharp dynamically loadable module (C)
# ----------------------------------------------------------------

csharp: $(SRCDIR_SRCS)
	$(SWIG) -csharp $(SWIGOPT) -o $(ISRCS) $(INTERFACEPATH)
	$(CC) -c $(CCSHARED) $(CPPFLAGS) $(CFLAGS) $(CSHARPCFLAGS) $(SRCDIR_SRCS) $(ISRCS) $(INCLUDES)
	$(LDSHARED) $(CFLAGS) $(LDFLAGS) $(OBJS) $(IOBJS) $(CSHARP_DLNK) $(LIBS) -o $(CSHARP_LIBPREFIX)$(TARGET)$(CSHARPSO)

# ----------------------------------------------------------------
# Build a CSharp dynamically loadable module (C++)
# ----------------------------------------------------------------

csharp_cpp: $(SRCDIR_SRCS)
	$(SWIG) -csharp -c++ $(SWIGOPT) -o $(ICXXSRCS) $(INTERFACEPATH)
	$(CXX) -c $(CCSHARED) $(CPPFLAGS) $(CXXFLAGS) $(CSHARPCFLAGS) $(SRCDIR_SRCS) $(SRCDIR_CXXSRCS) $(ICXXSRCS) $(INCLUDES)
	$(CXXSHARED) $(CXXFLAGS) $(LDFLAGS) $(OBJS) $(IOBJS) $(CSHARP_DLNK) $(LIBS) $(CPP_DLLIBS) -o $(CSHARP_LIBPREFIX)$(TARGET)$(CSHARPSO)

# ----------------------------------------------------------------
# Compile CSharp files
# ----------------------------------------------------------------

ifneq (,$(SRCDIR))
SRCDIR_CSHARPSRCS = $(addprefix $(SRCDIR),$(CSHARPSRCS))
else
SRCDIR_CSHARPSRCS =
endif

csharp_compile: $(SRCDIR_SRCS)
	$(COMPILETOOL) $(CSHARPCOMPILER) $(CSHARPFLAGS) $(CSHARPOPTIONS) $(CSHARPSRCS) $(SRCDIR_CSHARPSRCS)

# -----------------------------------------------------------------
# Run CSharp example
# -----------------------------------------------------------------

csharp_run:
	env LD_LIBRARY_PATH=$$PWD $(RUNTOOL) $(CSHARP_RUNME) $(RUNPIPE)

# -----------------------------------------------------------------
# Version display
# -----------------------------------------------------------------

# Version check below also works with MS csc.exe which does not understand --version
csharp_version:
	$(CSHARPCOMPILER) --version | head -n 1
	if test -n "$(CSHARPCILINTERPRETER)" ; then "$(CSHARPCILINTERPRETER)" --version ; fi

# -----------------------------------------------------------------
# Cleaning the CSharp examples
# -----------------------------------------------------------------

csharp_clean:
	rm -f *_wrap* *~ .~* $(RUNME) $(RUNME).exe *.exe.mdb gc.log `find . -name \*.cs | grep -v $(RUNME).cs`
	rm -f core 
	rm -f *.o *.so

##################################################################
#####                      LUA                              ######
##################################################################

# lua flags
LUA_INCLUDE= 
LUA_LIB    = 

# Extra specific dynamic linking options
LUA_DLNK   = 
LUA_SO     = .so

LUA        = 
LUA_SCRIPT = $(SRCDIR)$(RUNME).lua

# Extra code for lua static link
LUA_INTERP = ../lua.c

# ----------------------------------------------------------------
# Build a C dynamically loadable module
# ----------------------------------------------------------------

lua: $(SRCDIR_SRCS)
	$(SWIG) -lua $(SWIGOPT) -o $(ISRCS) $(INTERFACEPATH)
	$(CC) -c $(CCSHARED) $(CPPFLAGS) $(CFLAGS) $(ISRCS) $(SRCDIR_SRCS) $(INCLUDES) $(LUA_INCLUDE)
	$(LDSHARED) $(CFLAGS) $(LDFLAGS) $(OBJS) $(IOBJS) $(LIBS) $(LUA_LIB) -o $(LIBPREFIX)$(TARGET)$(LUA_SO)

# -----------------------------------------------------------------
# Build a C++ dynamically loadable module
# -----------------------------------------------------------------

lua_cpp: $(SRCDIR_SRCS) $(GENCXXSRCS)
	$(SWIG) -c++ -lua $(SWIGOPT) -o $(ICXXSRCS) $(INTERFACEPATH)
	$(CXX) -c $(CCSHARED) $(CPPFLAGS) $(CXXFLAGS) $(ICXXSRCS) $(SRCDIR_SRCS) $(SRCDIR_CXXSRCS) $(GENCXXSRCS) $(INCLUDES) $(LUA_INCLUDE)
	$(CXXSHARED) $(CXXFLAGS) $(LDFLAGS) $(OBJS) $(IOBJS) $(LIBS) $(LUA_LIB) $(CPP_DLLIBS) -o $(LIBPREFIX)$(TARGET)$(LUA_SO)

lua_externalhdr:
	$(SWIG) -lua -external-runtime $(TARGET)

lua_swig_cpp:
	$(SWIG) -c++ -lua $(SWIGOPT) -o $(ICXXSRCS) $(INTERFACEPATH)

# -----------------------------------------------------------------
# Build statically linked Lua interpreter
# -----------------------------------------------------------------

lua_static: $(SRCDIR_SRCS)
	$(SWIG) -lua -module example $(SWIGOPT) -o $(ISRCS) $(INTERFACEPATH)
	$(CC) $(CPPFLAGS) $(CFLAGS) $(LDFLAGS)  $(ISRCS) $(SRCDIR_SRCS) $(SRCDIR)$(LUA_INTERP) $(INCLUDES) \
	$(LUA_INCLUDE) $(LIBS) $(LUA_LIB) -o $(TARGET)

lua_static_cpp: $(SRCDIR_SRCS) $(GENCXXSRCS)
	$(SWIG) -c++ -lua -module example $(SWIGOPT) -o $(ICXXSRCS) $(INTERFACEPATH)
	$(CXX) $(CPPFLAGS) $(CXXFLAGS) $(LDFLAGS) $(ICXXSRCS) $(SRCDIR_SRCS) $(SRCDIR_CXXSRCS) $(GENCXXSRCS) $(SRCDIR)$(LUA_INTERP) $(INCLUDES) \
	$(LUA_INCLUDE) $(LIBS)  $(LUA_LIB) -o $(TARGET)

# -----------------------------------------------------------------
# Run Lua example
# -----------------------------------------------------------------

lua_run:
	$(RUNTOOL) $(LUA) $(LUA_SCRIPT) $(RUNPIPE)

lua_embed_run:
	$(RUNTOOL) ./$(TARGET) $(LUA_SCRIPT) $(RUNPIPE)

# -----------------------------------------------------------------
# Version display
# -----------------------------------------------------------------

lua_version:
	$(LUA) -v | head -n 1

# -----------------------------------------------------------------
# Cleaning the lua examples
# -----------------------------------------------------------------

lua_clean:
	rm -f *_wrap* *~ .~* mylua
	rm -f core 
	rm -f *.o *$(LUA_SO)

##################################################################
#####                   ALLEGRO CL                          ######
##################################################################

ALLEGROCL    = 
ALLEGROCL_SCRIPT=$(RUNME).lisp

allegrocl: $(SRCDIR_SRCS)
	$(SWIG) -allegrocl -cwrap $(SWIGOPT) -o $(ISRCS) $(INTERFACEPATH)
	$(CC) -c $(CCSHARED) $(CPPFLAGS) $(CFLAGS) $(ISRCS) $(INCLUDES) $(SRCDIR_SRCS)
	$(LDSHARED) $(CFLAGS) $(LDFLAGS) $(OBJS) $(IOBJS) $(LIBS) -o $(LIBPREFIX)$(TARGET)$(SO)

allegrocl_cpp: $(SRCDIR_SRCS)
	$(SWIG) -c++ -allegrocl $(SWIGOPT) -o $(ICXXSRCS) $(INTERFACEPATH)
	$(CXX) -c $(CCSHARED) $(CPPFLAGS) $(CXXFLAGS) $(ICXXSRCS) $(SRCDIR_SRCS) $(SRCDIR_CXXSRCS) $(INCLUDES)
	$(CXXSHARED) $(CXXFLAGS) $(LDFLAGS) $(OBJS) $(IOBJS) $(LIBS) $(CPP_DLLIBS) -o $(LIBPREFIX)$(TARGET)$(SO)

# -----------------------------------------------------------------
# Run ALLEGRO CL example
# -----------------------------------------------------------------

allegrocl_run:
	$(RUNTOOL) $(ALLEGROCL) -batch -s $(ALLEGROCL_SCRIPT) $(RUNPIPE)

# -----------------------------------------------------------------
# Version display
# -----------------------------------------------------------------

allegrocl_version:
	$(ALLEGROCL) --version

# -----------------------------------------------------------------
# Cleaning the ALLEGRO CL examples
# -----------------------------------------------------------------

allegrocl_clean:
	rm -f *_wrap* *~ .~*
	rm -f core 
	rm -f *.o *.so

##################################################################
#####                      CLISP                            ######
##################################################################

CLISP = 
CLISP_SCRIPT=$(RUNME).lisp

clisp: $(SRCDIR_SRCS)
	$(SWIG) -clisp $(SWIGOPT) -o $(ISRCS) $(INTERFACEPATH)

clisp_cpp: $(SRCDIR_SRCS)
	$(SWIG) -c++ -clisp $(SWIGOPT) -o $(ICXXSRCS) $(INTERFACEPATH)

# -----------------------------------------------------------------
# Run CLISP example
# -----------------------------------------------------------------

clisp_run:
	$(RUNTOOL) $(CLISP) -batch -s $(CLISP_SCRIPT) $(RUNPIPE)

# -----------------------------------------------------------------
# Version display
# -----------------------------------------------------------------

clisp_version:
	$(CLISP) --version | head -n 1

# -----------------------------------------------------------------
# Cleaning the CLISP examples
# -----------------------------------------------------------------

clisp_clean:
	rm -f *_wrap* *~ .~*
	rm -f core 
	rm -f *.o *.so

##################################################################
#####                      CFFI                             ######
##################################################################

CFFI = @CFFIBIN@
CFFI_SCRIPT=$(RUNME).lisp

cffi: $(SRCDIR_SRCS)
	$(SWIG) -cffi $(SWIGOPT) -o $(ISRCS) $(INTERFACEPATH)
#	$(CC) -c $(CCSHARED) $(CPPFLAGS) $(CFLAGS) $(ISRCS) $(INCLUDES) $(SRCDIR_SRCS)
#	$(LDSHARED) $(CFLAGS) $(LDFLAGS) $(OBJS) $(IOBJS) $(LIBS) -o $(LIBPREFIX)$(TARGET)$(SO)

cffi_cpp: $(SRCDIR_SRCS)
	$(SWIG) -c++ -cffi $(SWIGOPT) -o $(ICXXSRCS) $(INTERFACEPATH)
	$(CXX) -c $(CCSHARED) $(CPPFLAGS) $(CXXFLAGS) $(ICXXSRCS) $(SRCDIR_SRCS) $(SRCDIR_CXXSRCS) $(INCLUDES)
	$(CXXSHARED) $(CXXFLAGS) $(LDFLAGS) $(OBJS) $(IOBJS) $(LIBS) $(CPP_DLLIBS) -o $(LIBPREFIX)$(TARGET)$(SO)

# -----------------------------------------------------------------
# Run CFFI example
# -----------------------------------------------------------------

cffi_run:
	$(RUNTOOL) $(CFFI) -batch -s $(CFFI_SCRIPT) $(RUNPIPE)

# -----------------------------------------------------------------
# Version display
# -----------------------------------------------------------------

cffi_version:
	$(CFFI) --version

# -----------------------------------------------------------------
# Cleaning the CFFI examples
# -----------------------------------------------------------------

cffi_clean:
	rm -f *_wrap* *~ .~*
	rm -f core 
	rm -f *.o *.so

##################################################################
#####                      UFFI                             ######
##################################################################

UFFI = @UFFIBIN@
UFFI_SCRIPT=$(RUNME).lisp

uffi: $(SRCDIR_SRCS)
	$(SWIG) -uffi $(SWIGOPT) -o $(ISRCS) $(INTERFACEPATH)
#	$(CC) -c $(CCSHARED) $(CPPFLAGS) $(CFLAGS) $(ISRCS) $(INCLUDES) $(SRCDIR_SRCS)
#	$(LDSHARED) $(CFLAGS) $(LDFLAGS) $(OBJS) $(IOBJS) $(LIBS) -o $(LIBPREFIX)$(TARGET)$(SO)

uffi_cpp: $(SRCDIR_SRCS)
	$(SWIG) -c++ -uffi $(SWIGOPT) -o $(ICXXSRCS) $(INTERFACEPATH)
#	$(CXX) -c $(CCSHARED) $(CPPFLAGS) $(CXXFLAGS) $(ICXXSRCS) $(SRCDIR_SRCS) $(SRCDIR_CXXSRCS) $(INCLUDES)
#	$(CXXSHARED) $(CXXFLAGS) $(LDFLAGS) $(OBJS) $(IOBJS) $(LIBS) $(CPP_DLLIBS) -o $(LIBPREFIX)$(TARGET)$(SO)

# -----------------------------------------------------------------
# Run UFFI example
# -----------------------------------------------------------------

uffi_run:
	$(RUNTOOL) $(UFFI) -batch -s $(UFFI_SCRIPT) $(RUNPIPE)

# -----------------------------------------------------------------
# Version display
# -----------------------------------------------------------------

uffi_version:
	$(UFFI) --version

# -----------------------------------------------------------------
# Cleaning the UFFI examples
# -----------------------------------------------------------------

uffi_clean:
	rm -f *_wrap* *~ .~*
	rm -f core 
	rm -f *.o *.so

##################################################################
#####                      R                                ######
##################################################################

R = R
RCXXSRCS = $(INTERFACE:.i=_wrap.cpp) #Need to use _wrap.cpp for R build system as it does not understand _wrap.cxx
RRSRC = $(INTERFACE:.i=.R)
R_CFLAGS=-fPIC
R_OPT = --slave --quiet --no-save --no-restore
R_SCRIPT=$(SRCDIR)$(RUNME).R

# need to compile .cxx files outside of R build system to make sure that
# we get -fPIC
# CMD SHLIB stdout is piped to /dev/null to prevent echo of compiler command

# ----------------------------------------------------------------
# Build a R dynamically loadable module (C)
# ----------------------------------------------------------------

r: $(SRCDIR_SRCS)
	$(SWIG) -r $(SWIGOPT) -o $(ISRCS) $(INTERFACEPATH)
ifneq ($(SRCDIR_SRCS),)
	$(CC) -g -c $(CPPFLAGS) $(CFLAGS) $(R_CFLAGS) $(SRCDIR_SRCS) $(INCLUDES)
endif
	+( PKG_CPPFLAGS="$(CPPFLAGS) $(INCLUDES)" $(COMPILETOOL) $(R) CMD SHLIB -o $(LIBPREFIX)$(TARGET)$(SO) $(ISRCS) $(OBJS) > /dev/null )

# ----------------------------------------------------------------
# Build a R dynamically loadable module (C++)
# ----------------------------------------------------------------
r_cpp: $(SRCDIR_CXXSRCS)
	$(SWIG) -c++ -r $(SWIGOPT) -o $(RCXXSRCS) $(INTERFACEPATH)
ifneq ($(SRCDIR_CXXSRCS),)
	$(CXX) -g -c $(CPPFLAGS) $(CXXFLAGS) $(R_CFLAGS) $(SRCDIR_CXXSRCS) $(INCLUDES)
endif
	+( PKG_CPPFLAGS="$(CPPFLAGS) $(INCLUDES)" $(COMPILETOOL) $(R) CMD SHLIB -o $(LIBPREFIX)$(TARGET)$(SO) $(RCXXSRCS) $(OBJS) > /dev/null )

# -----------------------------------------------------------------
# Run R example
# -----------------------------------------------------------------

r_run:
	$(RUNTOOL) $(R) $(R_OPT) -f $(R_SCRIPT) $(RUNPIPE)

# -----------------------------------------------------------------
# Version display
# -----------------------------------------------------------------

r_version:
	$(R) --version | head -n 1

# -----------------------------------------------------------------
# Cleaning the R examples
# -----------------------------------------------------------------

r_clean:
	rm -f *_wrap* *~ .~*
	rm -f core 
	rm -f *.o *.so NAMESPACE
	rm -f $(RRSRC) $(RUNME).Rout .RData

##################################################################
#####                 SCILAB                                ######
##################################################################

SCILAB = 
SCILAB_INC= 
SCILAB_OPT = 
SCILAB_LIBPREFIX = lib

# ----------------------------------------------------------------
# Build a C dynamically loadable module
# ----------------------------------------------------------------

scilab:
	$(SWIG) -scilab $(SWIGOPT) -o $(ISRCS) $(INTERFACEPATH)
	$(CC) -g -c $(CCSHARED) $(CPPFLAGS) $(CFLAGS) $(SCILAB_INC) $(INCLUDES) $(ISRCS) $(SRCDIR_SRCS) $(SRCDIR_CSRCS)
	$(LDSHARED) $(CFLAGS) $(LDFLAGS) $(IOBJS) $(OBJS) $(LIBS) -o $(SCILAB_LIBPREFIX)$(TARGET)$(SO)

# ----------------------------------------------------------------
# Build a C++ dynamically loadable module
# ----------------------------------------------------------------

scilab_cpp:
	$(SWIG) -c++ -scilab $(SWIGOPT) -o $(ICXXSRCS) $(INTERFACEPATH)
	$(CXX) -g -c $(CCSHARED) $(CPPFLAGS) $(CXXFLAGS) $(SCILAB_INC) $(INCLUDES) $(ICXXSRCS) $(SRCDIR_SRCS) $(SRCDIR_CXXSRCS)
	$(CXXSHARED) $(CXXFLAGS) $(LDFLAGS) $(IOBJS) $(OBJS) $(LIBS) $(CPP_DLLIBS) -o $(SCILAB_LIBPREFIX)$(TARGET)$(SO)

# -----------------------------------------------------------------
# Running a Scilab example
# -----------------------------------------------------------------

scilab_run:
	env LD_LIBRARY_PATH=$$PWD $(RUNTOOL) $(SCILAB) $(SCILAB_OPT) -f $(SRCDIR)$(RUNME).sci $(RUNPIPE)

# -----------------------------------------------------------------
# Scilab version
# -----------------------------------------------------------------

scilab_version:
	echo `$(SCILAB) -version | head -1`

# -----------------------------------------------------------------
# Cleaning the scilab examples
# -----------------------------------------------------------------

scilab_clean:
	rm -f *_wrap* *~ .~*
	rm -f core 
	rm -f *.o *.so
	rm -f *.sce

##################################################################
#####                        Go                             ######
##################################################################

# TODO: The Go make targets need simplifying to use configure time
# configuration or to use Make's ifeq rather than using lots of
# runtime shell code. The output will then be a lot less verbose.

GO = 
GOGCC = false
GCCGO = 
GO1 = false
GO12 = false
GO13 = false
GO15 = false
GOC = 
GOOPT = 
GCCGOOPT = 
GOVERSIONOPTION = 

GOSWIGARG = `if $(GOGCC) ; then echo -gccgo; fi`
GOCOMPILEARG = `if $(GO15); then echo tool compile; elif $(GO1) ; then echo tool $(GOC:c=g) ; fi` `if $(GO13) || $(GO15); then echo -pack ; fi`

GOSRCS = $(INTERFACE:.i=.go)
GOCSRCS = $(INTERFACE:.i=_gc.c)

GOLD = `if $(GO15); then echo link; else echo $(GOC:c=l); fi`
GOTOOL = `if $(GO1) ; then echo go tool; fi`
GOPACK = `if $(GO1) ; then echo go tool pack; else echo gopack; fi`

GOPACKAGE = $(notdir $(INTERFACE:.i=.a))

GOPATHDIR = gopath/src/$(INTERFACE:.i=)

GOOBJEXT = `if $(GO15); then echo o; else echo $(GOC:c=); fi`
GOGCOBJS = $(GOSRCS:.go=.$(GOOBJEXT))
GOGCCOBJS = $(GOSRCS:.go=.o)

# ----------------------------------------------------------------
# Build a Go module (C)
# ----------------------------------------------------------------

go_nocgo: $(SRCDIR_SRCS)
	$(SWIG) -go $(GOOPT) $(GOSWIGARG) $(SWIGOPT) -o $(ISRCS) $(INTERFACEPATH)
	if $(GO12) || $(GO13) || $(GO15) || $(GOGCC); then \
	  $(CC) -g -c $(CPPFLAGS) $(CFLAGS) $(SRCDIR_SRCS) $(ISRCS) $(INCLUDES); \
	else \
	  $(CC) -g -c $(CCSHARED) $(CPPFLAGS) $(CFLAGS) $(SRCDIR_SRCS) $(ISRCS) $(INCLUDES); \
	  $(LDSHARED) $(CFLAGS) $(LDFLAGS) $(OBJS) $(IOBJS) $(LIBS) -o $(LIBPREFIX)$(TARGET)$(SO); \
	fi
	if $(GOGCC) ; then \
	  $(COMPILETOOL) $(GCCGO) -g -c -I . $(GOSRCS); \
	else \
	  $(COMPILETOOL) $(GO) $(GOCOMPILEARG) -I . $(GOSRCS); \
	  $(COMPILETOOL) $(GOTOOL) $(GOC) -I $${GOROOT:-`go env GOROOT`}/pkg/$${GOOS:-`go env GOOS`}_$${GOARCH:-`go env GOARCH`} $(GOCSRCS); \
	  rm -f $(GOPACKAGE); \
	  if $(GO13) || $(GO15); then \
	    cp $(GOGCOBJS) $(GOPACKAGE); \
	    $(COMPILETOOL) $(GOPACK) r $(GOPACKAGE) $(GOCSRCS:.c=.$(GOOBJEXT)) $(OBJS) $(IOBJS); \
	  elif $(GO12); then \
	    $(COMPILETOOL) $(GOPACK) grc $(GOPACKAGE) $(GOGCOBJS) $(GOCSRCS:.c=.$(GOOBJEXT)) $(OBJS) $(IOBJS); \
	  else \
	    $(COMPILETOOL) $(GOPACK) grc $(GOPACKAGE) $(GOGCOBJS) $(GOCSRCS:.c=.$(GOOBJEXT)); \
	  fi; \
	fi
	if test -f $(SRCDIR)$(RUNME).go; then \
	  if $(GOGCC) ; then \
	    $(COMPILETOOL) $(GCCGO) -g -c $(SRCDIR)$(RUNME).go; \
	    $(COMPILETOOL) $(GCCGO) -o $(RUNME) $(RUNME).o $(GOGCCOBJS) $(OBJS) $(IOBJS); \
	  elif $(GO12) || $(GO13) || $(GO15); then \
	    $(GO) $(GOCOMPILEARG) $(SRCDIR)$(RUNME).go; \
	    $(COMPILETOOL) $(GOTOOL) $(GOLD) -linkmode external -extld "$(CC)" -extldflags "$(CFLAGS) $(LDFLAGS)" -o $(RUNME) $(RUNME).$(GOOBJEXT); \
	  else \
	    $(GO) $(GOCOMPILEARG) $(SRCDIR)$(RUNME).go; \
	    $(COMPILETOOL) $(GOTOOL) $(GOLD) -r $${GOROOT:-`go env GOROOT`}/pkg/$${GOOS:-`go env GOOS`}_$${GOARCH:-`go env GOARCH`}:. -o $(RUNME) $(RUNME).$(GOOBJEXT); \
	  fi; \
	fi

go: $(SRCDIR_SRCS)
	$(SWIG) -go -cgo $(GOOPT) $(GOSWIGARG) $(SWIGOPT) -o $(ISRCS) $(INTERFACEPATH)
	@mkdir gopath 2>/dev/null || true
	@mkdir gopath/src 2>/dev/null || true
	@mkdir gopath/src/$(INTERFACE:.i=) 2>/dev/null || true
	rm -f $(GOPATHDIR)/*
	cp $(ISRCS) $(GOPATHDIR)/
	if test -f $(IWRAP:.i=.h); then \
	  cp $(IWRAP:.i=.h) $(GOPATHDIR)/; \
	fi
	if test -n "$(SRCDIR_SRCS)"; then \
	  cp $(SRCDIR_SRCS) $(GOPATHDIR)/; \
	fi
	cp $(GOSRCS) $(GOPATHDIR)/
	GOPATH=`pwd`/gopath; \
	export GOPATH; \
	CGO_CPPFLAGS="$(CPPFLAGS) $(INCLUDES) -I `cd $(SRCDIR) && pwd` -I `pwd`"; \
	export CGO_CPPFLAGS; \
	CGO_CFLAGS="$(CFLAGS)"; \
	export CGO_CFLAGS; \
	CGO_LDFLAGS="$(LDFLAGS) -lm"; \
	export CGO_LDFLAGS; \
	(cd $(GOPATHDIR)/ && $(COMPILETOOL) $(GO) build `if $(GOGCC); then echo -compiler=gccgo; fi` -o $(GOPACKAGE))
	cp $(GOPATHDIR)/$(GOPACKAGE) $(dir $(INTERFACE))/$(GOPACKAGE)
	if $(GOGCC); then \
	  cp $(dir $(INTERFACE))/$(GOPACKAGE) $(dir $(INTERFACE))/$(GOPACKAGE:.a=.gox); \
	fi
	if test -f $(SRCDIR)$(RUNME).go; then \
	  if $(GOGCC) ; then \
	    $(COMPILETOOL) $(GCCGO) -c -g $(SRCDIR)$(RUNME).go; \
	    $(COMPILETOOL) $(GCCGO) -o $(RUNME) $(RUNME).o $(dir $(INTERFACE))/$(GOPACKAGE); \
	  elif $(GO12) || $(GO13) || $(GO15); then \
	    $(COMPILETOOL) $(GO) $(GOCOMPILEARG) -o $(RUNME).$(GOOBJEXT) $(SRCDIR)$(RUNME).go; \
	    $(COMPILETOOL) $(GOTOOL) $(GOLD) -linkmode external -extld "$(CC)" -extldflags "$(CFLAGS) $(LDFLAGS)" -o $(RUNME) $(RUNME).$(GOOBJEXT); \
	  else \
	    $(COMPILETOOL) $(GO) $(GOCOMPILEARG) $(SRCDIR)$(RUNME).go; \
	    $(COMPILETOOL) $(GOTOOL) $(GOLD) -r $${GOROOT:-`go env GOROOT`}/pkg/$${GOOS:-`go env GOOS`}_$${GOARCH:-`go env GOARCH`}:. -o $(RUNME) $(RUNME).$(GOOBJEXT); \
	  fi; \
	fi

# ----------------------------------------------------------------
# Build a Go module (C++)
# ----------------------------------------------------------------

go_cpp_nocgo: $(SRCDIR_SRCS)
	$(SWIG) -go -c++ $(GOOPT) $(GOSWIGARG) $(SWIGOPT) -o $(ICXXSRCS) $(INTERFACEPATH)
	if $(GO12) || $(GO13) || $(GO15) || $(GOGCC); then \
	  if test -n "$(SRCDIR_CXXSRCS)$(SRCDIR_SRCS)"; then \
	    $(CXX) -g -c $(CPPFLAGS) $(CXXFLAGS) $(SRCDIR_CXXSRCS) $(SRCDIR_SRCS) $(INCLUDES); \
	  fi; \
	  $(foreach f,$(ICXXSRCS), \
	    $(CXX) -g -c $(CPPFLAGS) $(CXXFLAGS) -o $(addsuffix .o,$(basename $f)) $f $(INCLUDES); \
	  ) \
	else \
	  $(CXX) -g -c $(CCSHARED) $(CPPFLAGS) $(CXXFLAGS) $(SRCDIR_SRCS) $(SRCDIR_CXXSRCS) $(ICXXSRCS) $(INCLUDES); \
	  $(CXXSHARED) $(CXXFLAGS) $(LDFLAGS) $(OBJS) $(IOBJS) $(LIBS) $(CPP_DLLIBS) -o $(LIBPREFIX)$(TARGET)$(SO); \
	fi
	if ! $(GOGCC) ; then \
	  $(foreach f,$(GOSRCS), \
	    $(COMPILETOOL) $(GO) $(GOCOMPILEARG) -I . -o $(addsuffix .$(GOOBJEXT),$(basename $f)) $f \
	  ); \
	  $(foreach f,$(GOCSRCS), \
	    $(COMPILETOOL) $(GOTOOL) $(GOC) -I $${GOROOT:-`go env GOROOT`}/pkg/$${GOOS:-`go env GOOS`}_$${GOARCH:-`go env GOARCH`} \
	    -o $(addsuffix .$(GOOBJEXT),$(basename $f)) $f; \
	  ) \
	  rm -f $(GOPACKAGE); \
	  if $(GO13) || $(GO15); then \
	    cp $(GOGCOBJS) $(GOPACKAGE); \
	    $(COMPILETOOL) $(GOPACK) r $(GOPACKAGE) $(GOCSRCS:.c=.$(GOOBJEXT)) $(OBJS) $(IOBJS); \
	  elif $(GO12); then \
	    $(COMPILETOOL) $(GOPACK) grc $(GOPACKAGE) $(GOGCOBJS) $(GOCSRCS:.c=.$(GOOBJEXT)) $(OBJS) $(IOBJS); \
	  else \
	    $(COMPILETOOL) $(GOPACK) grc $(GOPACKAGE) $(GOGCOBJS) $(GOCSRCS:.c=.$(GOOBJEXT)); \
	  fi; \
	else \
	  $(foreach f,$(GOSRCS), \
	    $(COMPILETOOL) $(GCCGO) -g -c -I . -o $(addsuffix .o,$(basename $f)) $f \
	  ); \
	fi
	if test -f $(SRCDIR)$(RUNME).go; then \
	  if $(GOGCC) ; then \
	    $(COMPILETOOL) $(GCCGO) -g -c $(SRCDIR)$(RUNME).go; \
	    $(COMPILETOOL) $(GCCGO) -o $(RUNME) $(RUNME).o $(GOGCCOBJS) $(OBJS) $(IOBJS) -lstdc++; \
	  elif $(GO12) || $(GO13) || $(GO15); then \
	    $(GO) $(GOCOMPILEARG) $(SRCDIR)$(RUNME).go; \
	    $(COMPILETOOL) $(GOTOOL) $(GOLD) -linkmode external -extld "$(CXX)" -extldflags "$(CXXFLAGS) $(LDFLAGS)" -o $(RUNME) $(RUNME).$(GOOBJEXT); \
	  else \
	    $(GO) $(GOCOMPILEARG) $(SRCDIR)$(RUNME).go; \
	    $(COMPILETOOL) $(GOTOOL) $(GOLD) -r $${GOROOT:-`go env GOROOT`}/pkg/$${GOOS:-`go env GOOS`}_$${GOARCH:-`go env GOARCH`}:. -o $(RUNME) $(RUNME).$(GOOBJEXT); \
	  fi; \
	fi

go_cpp: $(SRCDIR_SRCS)
	$(SWIG) -go -c++ -cgo $(GOOPT) $(GOSWIGARG) $(SWIGOPT) -o $(ICXXSRCS) $(INTERFACEPATH)
	@mkdir gopath 2>/dev/null || true
	@mkdir gopath/src 2>/dev/null || true
	@mkdir gopath/src/$(INTERFACE:.i=) 2>/dev/null || true
	rm -f $(GOPATHDIR)/*
	cp $(ICXXSRCS) $(GOPATHDIR)/
	if test -f $(IWRAP:.i=.h); then \
	  cp $(IWRAP:.i=.h) $(GOPATHDIR)/; \
	fi
	if test -n "$(SRCDIR_CXXSRCS)"; then \
	  cp $(SRCDIR_CXXSRCS) $(GOPATHDIR)/; \
	fi
	if test -n "$(SRCDIR_SRCS)"; then \
	  cp $(SRCDIR_SRCS) $(GOPATHDIR)/; \
	fi
	cp $(GOSRCS) $(GOPATHDIR)/
	GOPATH=`pwd`/gopath; \
	export GOPATH; \
	CGO_CPPFLAGS="$(CPPFLAGS) $(INCLUDES) -I `cd $(SRCDIR) && pwd` -I `pwd`"; \
	export CGO_CPPFLAGS; \
	CGO_CFLAGS="$(CFLAGS)"; \
	export CGO_CFLAGS; \
	CGO_CXXFLAGS="$(CXXFLAGS)"; \
	export CGO_CXXFLAGS; \
	CGO_LDFLAGS="$(LDFLAGS) -lm"; \
	export CGO_LDFLAGS; \
	(cd $(GOPATHDIR) && $(COMPILETOOL) $(GO) build `if $(GOGCC); then echo -compiler=gccgo; fi` -o $(GOPACKAGE))
	cp $(GOPATHDIR)/$(GOPACKAGE) $(dir $(INTERFACE))/$(GOPACKAGE)
	if $(GOGCC); then \
	  cp $(dir $(INTERFACE))/$(GOPACKAGE) $(dir $(INTERFACE))/$(GOPACKAGE:.a=.gox); \
	fi
	if test -f $(SRCDIR)$(RUNME).go; then \
	  if $(GOGCC) ; then \
	    $(COMPILETOOL) $(GCCGO) -g -c $(SRCDIR)$(RUNME).go; \
	    $(COMPILETOOL) $(GCCGO) -o $(RUNME) $(RUNME).o $(dir $(INTERFACE))/$(GOPACKAGE) -lstdc++; \
	  elif $(GO12) || $(GO13) || $(GO15); then \
	    $(COMPILETOOL) $(GO) $(GOCOMPILEARG) -o $(RUNME).$(GOOBJEXT) $(SRCDIR)$(RUNME).go; \
	    $(COMPILETOOL) $(GOTOOL) $(GOLD) -linkmode external -extld "$(CXX)" -extldflags "$(CXXFLAGS) $(LDFLAGS)" -o $(RUNME) $(RUNME).$(GOOBJEXT); \
	  else \
	    $(COMPILETOOL) $(GO) $(GOCOMPILEARG) $(SRCDIR)$(RUNME).go; \
	    $(COMPILETOOL) $(GOTOOL) $(GOLD) -r $${GOROOT:-`go env GOROOT`}/pkg/$${GOOS:-`go env GOOS`}_$${GOARCH:-`go env GOARCH`}:. -o $(RUNME) $(RUNME).$(GOOBJEXT); \
	  fi; \
	fi

# -----------------------------------------------------------------
# Running Go example
# -----------------------------------------------------------------

go_run:
	env $(RUNTOOL) ./$(RUNME) $(RUNPIPE)

# -----------------------------------------------------------------
# Version display
# -----------------------------------------------------------------

go_version:
	$(GO) $(GOVERSIONOPTION)

# -----------------------------------------------------------------
# Cleaning the Go examples
# -----------------------------------------------------------------

go_clean:
	rm -f *_wrap* *_gc* *.gox .~* $(RUNME) $(GOSRCS)
	rm -rf gopath
	rm -f core 
	rm -f *.o *.[568] *.a *.so

##################################################################
#####                         D                             ######
##################################################################

DLIBPREFIX = lib

ifeq (,$(D_VERSION))
  D_VERSION = 
endif

ifeq (2,$(D_VERSION))
  SWIGD = $(SWIG) -d -d2
  DCOMPILER = 
else
  SWIGD = $(SWIG) -d
  DCOMPILER = 
endif

D_RUNME = ./$(RUNME)

# ----------------------------------------------------------------
# Build a dynamically loadable D wrapper for a C module
# ----------------------------------------------------------------

d: $(SRCDIR_SRCS)
	$(SWIGD) $(SWIGOPT) -o $(ISRCS) $(INTERFACEPATH)
	$(CC) -c $(CCSHARED) $(CPPFLAGS) $(CFLAGS) $(DCFLAGS) $(EXTRA_CFLAGS) $(SRCDIR_SRCS) $(ISRCS) $(INCLUDES)
	$(LDSHARED) $(CFLAGS) $(LDFLAGS) $(DCFLAGS) $(EXTRA_LDFLAGS) $(OBJS) $(IOBJS) $(LIBS) -o $(DLIBPREFIX)$(TARGET)$(SO)

# ----------------------------------------------------------------
# Build a dynamically loadable D wrapper for a C++ module
# ----------------------------------------------------------------

d_cpp: $(SRCDIR_SRCS)
	$(SWIGD) -c++ $(SWIGOPT) -o $(ICXXSRCS) $(INTERFACEPATH)
	$(CXX) -c $(CCSHARED) $(CPPFLAGS) $(CXXFLAGS) $(DCFLAGS) $(EXTRA_CFLAGS) $(SRCDIR_SRCS) $(SRCDIR_CXXSRCS) $(ICXXSRCS) $(INCLUDES)
	$(CXXSHARED) $(CXXFLAGS) $(LDFLAGS) $(DCFLAGS) $(EXTRA_LDFLAGS) $(OBJS) $(IOBJS) $(LIBS) $(CPP_DLLIBS) -o $(DLIBPREFIX)$(TARGET)$(SO)

# ----------------------------------------------------------------
# Compile D files
# ----------------------------------------------------------------

# Clear the DFLAGS environment variable for the compiler call itself
# to work around a discrepancy in argument handling between DMD and LDC.
d_compile: $(SRCDIR_SRCS)
	DFLAGS="" $(COMPILETOOL) $(DCOMPILER) $(DFLAGS) $(DSRCS)

# -----------------------------------------------------------------
# Run D example
# -----------------------------------------------------------------

d_run:
	env LD_LIBRARY_PATH=$$PWD $(RUNTOOL) $(D_RUNME) $(RUNPIPE)

# -----------------------------------------------------------------
# Version display
# -----------------------------------------------------------------

d_version:
	# Needs improvement!
	echo D version guess - $(D_VERSION)

# -----------------------------------------------------------------
# Clean the D examples
# -----------------------------------------------------------------

d_clean:
	rm -f *_wrap* *~ .~* $(RUNME) $(RUNME).exe `find . -name \*.d | grep -v $(RUNME).d`
	rm -f core 
	rm -f *.o *.so
