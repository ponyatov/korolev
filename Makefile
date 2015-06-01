.PHONY: none
none:
	echo "use make <package>"

include azlin/mk/versions.mk
include azlin/mk/packages.mk

# dirs

GZ = $(HOME)/gz
SRC = $(HOME)/src
TMP = /tmp/$(USER)
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

# optimization for Xeon X5570
BOPT = -mtune=barcelona -ffast-math -O3 -msse4.2

MAKE = $(XPATH) make -j$(CPU_CORES)

# packages

# most new cross

.PHONY: cross
cross: binutils

.PHONY: binutils
binutils:

BLAS_CFG = \
	FORTRAN=gfortran OPTS="$(BOPT)" \
	BLASLIB=$(LIB)/libblas.a
	
.PHONY: blas
blas: $(SRC)/$(BLAS)/README
	cd $(SRC)/$(BLAS) &&\
	touch make.inc &&\
	make clean &&\
	$(MAKE) $(BLAS_CFG)
#	echo $(FORTRAN) $(F77FLAGS) -o $(LIB)/libblas.a
#	 $(SRC)/$(BLAS)/*.f
 