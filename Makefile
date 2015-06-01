
TARGET = $(shell gcc -dumpmachine) 

.PHONY: none
none:
	echo "use make <package>"

include azlin/mk/versions.mk
ISL_VER = 0.11.1

include azlin/mk/packages.mk

# dirs

GZ = $(HOME)/gz
TMP = /tmp/$(USER)
SRC = $(TMP)/src
BIN = $(HOME)/bin
LIB = $(HOME)/lib
TC = $(TMP)/build
ROOT = $(TMP)/target

DIRS = $(GZ) $(SRC) $(TMP) $(BIN) $(LIB) $(TC) $(ROOT)

.PHONY: dirs
dirs:
	mkdir -p $(DIRS)
	
# commands

XPATH = PATH=$(HOME)/bin:$(PATH)
CPU_CORES ?= $(shell grep processor /proc/cpuinfo |wc -l) 

MAKE = $(XPATH) make -j$(CPU_CORES)
INSTALL = make install

WGET = -wget -N -P $(GZ)

BCC = gcc -pipe
BXX = g++ -pipe

# sources

.PHONY: gz
gz:
	$(WGET) ftp://gcc.gnu.org/pub/gcc/infrastructure/$(ISL).tar.bz2

include azlin/mk/src.mk

# optimization
## build system: Xeon X5570
BOPT = -ffast-math -O3 -g0
## target system: Xeon X5570 / self-build $(GCC)
TOPT = -mtune=barcelona -ffast-math -O3 -msse4.2

# configuration
CFG = configure --disable-nls --disable-werror \
	--docdir=$(TMP)/doc --mandir=$(TMP)/doc/man --infodir=$(TMP)/doc/info

BCFG = $(CFG) --prefix=$(TC) \
	CC="$(BCC)" CXX="$(BXX)" CFLAGS="$(BOPT)" CXXFLAGS="$(BOPT)"

TCFG = $(CFG) --prefix=$(ROOT) \
	CC="$(TCC)" CXX="$(TXX)" CFLAGS="$(TOPT)" CXXFLAGS="$(TOPT)"

# packages

## most new cross

.PHONY: cross
cross: cclibs binutils

### libs required for binutils/gcc build

CCLIBS_CFG_ALL = --disable-shared
CCLIBS_CFG_WITH = --with-gmp=$(TC) --with-mpfr=$(TC) --with-mpc=$(TC) \
	--with-isl=$(TC) --with-cloog=$(TC)
CCLIBS_CFG = $(CCLIBS_CFG_ALL) $(CCLIBS_CFG_WITH) 
.PHONY: cclibs
cclibs: gmp mpfr mpc cloog isl

GMP_CFG = $(CCLIBS_CFG)
.PHONY: gmp
gmp: $(SRC)/$(GMP)/README
	rm -rf $(TMP)/$(GMP) && mkdir $(TMP)/$(GMP) && cd $(TMP)/$(GMP) &&\
	$(SRC)/$(GMP)/$(BCFG) $(GMP_CFG) && $(MAKE) && $(INSTALL)-strip

MPFR_CFG = $(CCLIBS_CFG)
.PHONY: mpfr
mpfr: $(SRC)/$(MPFR)/README
	rm -rf $(TMP)/$(MPFR) && mkdir $(TMP)/$(MPFR) && cd $(TMP)/$(MPFR) &&\
	$(SRC)/$(MPFR)/$(BCFG) $(MPFR_CFG) && $(MAKE) && $(INSTALL)-strip

MPC_CFG = $(CCLIBS_CFG)
.PHONY: mpc
mpc: $(SRC)/$(MPC)/README
	rm -rf $(TMP)/$(MPC) && mkdir $(TMP)/$(MPC) && cd $(TMP)/$(MPC) &&\
	$(SRC)/$(MPC)/$(BCFG) $(MPC_CFG) && $(MAKE) && $(INSTALL)-strip
	
CLOOG_CFG = --with-gmp-prefix=$(TC) $(CCLIBS_CFG_ALL)
.PHONY: cloog
cloog: $(SRC)/$(CLOOG)/README
	rm -rf $(TMP)/$(CLOOG) && mkdir $(TMP)/$(CLOOG) && cd $(TMP)/$(CLOOG) &&\
	$(SRC)/$(CLOOG)/$(BCFG) $(CLOOG_CFG) && $(MAKE) && $(INSTALL)-strip

ISL_CFG = --with-gmp-prefix=$(TC) $(CCLIBS_CFG_ALL)
.PHONY: isl
isl: $(SRC)/$(ISL)/README
	rm -rf $(TMP)/$(ISL) && mkdir $(TMP)/$(ISL) && cd $(TMP)/$(ISL) &&\
	$(SRC)/$(ISL)/$(BCFG) $(ISL_CFG) && $(MAKE) && $(INSTALL)-strip


CFG_BINUTILS = $(CCLIBS_CFG_WITH) --target=$(TARGET) --disable-bootstrap
.PHONY: binutils
binutils: $(SRC)/$(BINUTILS)/README
	rm -rf $(TMP)/$(BINUTILS) && mkdir $(TMP)/$(BINUTILS) &&\
	cd $(TMP)/$(BINUTILS) &&\
	$(SRC)/$(BINUTILS)/$(BCFG) $(CFG_BINUTILS) &&\
	$(MAKE) && $(INSTALL)-strip

BLAS_CFG = \
	FORTRAN=gfortran OPTS="$(BOPT)" \
	BLASLIB=$(LIB)/libblas.a
.PHONY: blas
blas: $(SRC)/$(BLAS)/README
	cd $(SRC)/$(BLAS) &&\
	touch make.inc &&\
	make clean &&\
	$(MAKE) $(BLAS_CFG)
