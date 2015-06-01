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

DIRS = $(GZ) $(SRC) $(TMP) $(BIN) $(LIB)

.PHONY: dirs
dirs:
	mkdir -p $(DIRS)
	
include azlin/mk/src.mk

# commands

XPATH = PATH=$(HOME)/bin:$(PATH)
CPU_CORES ?= $(shell grep processor /proc/cpuinfo |wc -l) 

# optimization
## build system 
BOPT = -O2 -g0
## target system: Xeon X5570
TOPT = -mtune=barcelona -ffast-math -O3 -msse4.2

MAKE = $(XPATH) make -j$(CPU_CORES)

# packages

# most new cross

.PHONY: cross
cross: binutils

CFG_BINUTILS = 
.PHONY: binutils
binutils: $(SRC)/$(BINUTILS)/README

BLAS_CFG = \
	FORTRAN=gfortran OPTS="$(BOPT)" \
	BLASLIB=$(LIB)/libblas.a
.PHONY: blas
blas: $(SRC)/$(BLAS)/README
	cd $(SRC)/$(BLAS) &&\
	touch make.inc &&\
	make clean &&\
	$(MAKE) $(BLAS_CFG)
