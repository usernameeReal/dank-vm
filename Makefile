# Master makefile of CollabVM Server

ifeq ($(OS), Windows_NT)

# Allow selection of w64 or w32 target

# Is it Cygwin?

ifeq ($(shell uname -s|cut -d _ -f 1), CYGWIN)

$(info Compiling targeting Cygwin)
MKCONFIG=mk/cygwin.mkc
BINDIR=bin/
ARCH=$(shell uname -m)
CYGWIN=1

else

CYGWIN=0

ifneq ($(WARCH), win32)

$(info Compiling targeting Win64)
MKCONFIG=mk/win64.mkc
ARCH=amd64
BINDIR=bin/win64/

else

$(info Compiling targeting x86 Windows)
MKCONFIG=mk/win32.mkc
BINDIR=bin/win32/
ARCH=x86

endif

endif

else

UNAMES := $(shell uname -s)

ifeq ($(UNAME_S),Darwin)

$(info Compiling targeting Darwin)
MKCONFIG=mk/bsd.mkc
BINDIR=bin/
ARCH=$(shell uname -m)

else ifeq ($(UNAME_S),FreeBSD)

$(info Compiling targeting FreeBSD)
MKCONFIG=mk/bsd.mkc
BINDIR=bin/
ARCH=$(shell uname -m)

else

# Assume Linux or other *nix-likes
$(info Compiling targeting *nix)
MKCONFIG=mk/linux.mkc
BINDIR=bin/
ARCH=$(shell uname -m)

endif

endif

# Set defaults for DEBUG and JPEG builds

ifeq ($(DEBUG),)
DEBUG = 0
endif

ifeq ($(JPEG),)
JPEG = 0
endif

ifeq ($(EXECINFO),)
EXECINFO = 0
endif

ifeq ($(UPNP),)
EXECINFO = 0
endif

ifeq ($(DEBUG),1)
$(info Building in debug mode)
else
$(info Building in release mode)
endif

ifeq ($(JPEG),1)
$(info Building JPEG support)
endif

ifeq ($(EXECINFO),1)
$(info Using libexecinfo for backtrace symbols)
endif

ifeq ($(UPNP),1)
$(info Building Universal Plug-and-Play support)
endif

.PHONY: all clean help

all:
	@$(MAKE) -f $(MKCONFIG) DEBUG=$(DEBUG) JPEG=$(JPEG) EXECINFO=$(EXECINFO)
	@./scripts/build_site.sh $(ARCH)
	-@ if [ -d "$(BINDIR)http" ]; then rm -rf $(BINDIR)http; fi;
	-@mv -f http/ $(BINDIR)
	@echo "Writing manpage for collab-vm-server..."
	@gzip doc/collab-vm-server.1 -kf
	@mv doc/collab-vm-server.1.gz $(BINDIR)
	@echo "Done."
ifeq ($(OS), Windows_NT)

ifeq ($(CYGWIN), 1)

	@./scripts/copy_dlls_cyg.sh $(ARCH) $(BINDIR)

else

	@./scripts/copy_dlls_mw.sh $(ARCH) $(BINDIR)

endif

endif

clean:
	@$(MAKE) -f $(MKCONFIG) clean

help:
	@echo -e "CollabVM Server 1.2.11 Makefile help:\n"
	@echo "make - Build release"
	@echo "make DEBUG=1 - Build a debug build (Adds extra trace information and debug symbols)"
	@echo "make JPEG=1 - Build with JPEG support (Useful for slower internet connections)"
	@echo "make EXECINFO=1 - Use libexecinfo for backtrace symbols (Required on some *nix)"
	@echo "make UPNP=1 - Build with UPnP support (Useful for some internet connections)"
