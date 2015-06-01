.PHONY: none
none:
	echo "use make <package>"

include azlin/mk/versions.mk
include azlin/mk/packages.mk

# dirs

GZ = $(HOME)/gz
TMP = /tmp/$(USER)
SRC = $(TMP)/src
BIN = $(HOME)/bin
LIB = $(HOME)/lib
BUILD = $(TMP)/build
TARGET = $(TMP)/target

DIRS = $(GZ) $(SRC) $(TMP) $(BIN) $(LIB) $(BUILD) $(TARGET)

.PHONY: dirs
dirs:
	mkdir -p $(DIRS)
	
include azlin/mk/src.mk

# commands

XPATH = PATH=$(HOME)/bin:$(PATH)
CPU_CORES ?= $(shell grep processor /proc/cpuinfo |wc -l) 

MAKE = $(XPATH) make -j$(CPU_CORES)
INSTALL = make install

BCC = gcc -pipe
BXX = g++ -pipe

# optimization
## build system: Xeon X5570
BOPT = -ffast-math -O3 -g0
## target system: Xeon X5570 / self-build $(GCC)
TOPT = -mtune=barcelona -ffast-math -O3 -msse4.2

# configuration
CFG = configure --disable-nls --disable-werror \
	--docdir=$(TMP)/doc --mandir=$(TMP)/doc/man --infodir=$(TMP)/doc/info

BCFG = $(CFG) --prefix=$(BUILD) \
	CC="$(BCC)" CXX="$(BXX)" CFLAGS="$(BOPT)" CXXFLAGS="$(BOPT)"

TCFG = $(CFG) --prefix=$(TARGET) \
	CC="$(TCC)" CXX="$(TXX)" CFLAGS="$(TOPT)" CXXFLAGS="$(TOPT)"

# packages

# most new cross

.PHONY: cross
cross: cclibs binutils

CCLIBS_CFG = --disable-shared \
	--with-gmp=$(TC) --with-mpfr=$(TC) --with-mpc=$(TC)
.PHONY: cclibs
cclibs: gmp mpfr mpc

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

GMP_CFG = $(CCLIBS_CFG)
.PHONY: gmp
gmp: $(SRC)/$(GMP)/README
	rm -rf $(TMP)/$(GMP) && mkdir $(TMP)/$(GMP) && cd $(TMP)/$(GMP) &&\
	$(SRC)/$(GMP)/$(BCFG) $(GMP_CFG) && $(MAKE) && $(INSTALL)-strip

CFG_BINUTILS = 
.PHONY: binutils
binutils: $(SRC)/$(BINUTILS)/README
	rm -rf $(TMP)/$(BINUTILS) && mkdir $(TMP)/$(BINUTILS) &&\
	cd $(TMP)/$(BINUTILS) &&\
	$(SRC)/$(BINUTILS)/$(BCFG) $(CFG_BINUTILS)
#	$(MAKE) && $(INSTALL)-strip

BLAS_CFG = \
	FORTRAN=gfortran OPTS="$(BOPT)" \
	BLASLIB=$(LIB)/libblas.a
.PHONY: blas
blas: $(SRC)/$(BLAS)/README
	cd $(SRC)/$(BLAS) &&\
	touch make.inc &&\
	make clean &&\
	$(MAKE) $(BLAS_CFG)
