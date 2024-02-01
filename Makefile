# Makefile for DeskLink2

OS ?= $(shell uname)
CC ?= gcc
CFLAGS += -O2 -Wall
#CFLAGS += -std=c99 -D_DEFAULT_SOURCE    # prove the code is still plain c
#CFLAGS += SHOWBYTES_A # bootstrap() display non-printing bytes differently
#CFLAGS += SHOWBYTES_B # bootstrap() display non-printing bytes differently
#CFLAGS += NADSBOX_EXTENSIONS # placeholder but not implemented
PREFIX ?= /usr/local
NAME := dl
APP_NAME := DeskLink2
APP_LIB_DIR := $(PREFIX)/lib/$(NAME)
APP_DOC_DIR := $(PREFIX)/share/doc/$(NAME)
APP_VERSION := $(shell git describe --long 2>&-)

CLIENT_LOADERS := \
	clients/teeny/TINY.100 \
	clients/teeny/D.100 \
	clients/teeny/TEENY.100 \
	clients/teeny/TEENY.200 \
	clients/teeny/TEENY.NEC \
	clients/teeny/TEENY.M10 \
	clients/dskmgr/DSKMGR.100 \
	clients/dskmgr/DSKMGR.200 \
	clients/dskmgr/DSKMGR.K85 \
	clients/dskmgr/DSKMGR.M10 \
	clients/ts-dos/TSLOAD.100 \
	clients/ts-dos/TSLOAD.200 \
	clients/ts-dos/TS-DOS.100 \
	clients/ts-dos/TS-DOS.200 \
	clients/ts-dos/TS-DOS.NEC \
	clients/pakdos/PAKDOS.100 \
	clients/pakdos/PAKDOS.200 \
	clients/disk_power/Disk_Power.K85 \
#	clients/power-dos/POWR-D.100

LIB_OTHER := \
	clients/ts-dos/DOS100.CO \
	clients/ts-dos/DOS200.CO \
	clients/ts-dos/DOSNEC.CO \
	clients/ts-dos/SAR100.CO \
	clients/ts-dos/SAR200.CO \
	clients/ts-dos/Sardine_American_English.pdd1 \
	clients/disk_power/Disk_Power.K85.pdd1

CLIENT_DOCS := \
	clients/teeny/teenydoc.txt \
	clients/teeny/hownec.do \
	clients/teeny/TNYO10.TXT \
	clients/teeny/tindoc.do \
	clients/teeny/ddoc.do \
	clients/dskmgr/DSKMGR.DOC \
	clients/ts-dos/tsdos.pdf \
	clients/pakdos/PAKDOS.DOC \
	clients/disk_power/Disk_Power.txt \
#	clients/power-dos/powr-d.txt

DOCS := dl.do README.txt README.md LICENSE $(CLIENT_DOCS)
SOURCES := dl.c dir_list.c
HEADERS := dir_list.h constants.h

ifeq ($(OS),Darwin)
 TTY_PREFIX := cu.usbserial
else
 ifneq (,$(findstring BSD,$(OS)))
  TTY_PREFIX := ttyU
 else ifeq ($(OS),Linux)
  TTY_PREFIX := ttyUSB
 else
  TTY_PREFIX := ttyS
 endif
 LDLIBS += -lutil
endif

INSTALLOWNER = -o root
ifeq ($(OS),Windows_NT)
 INSTALLOWNER =
 CFLAGS += -D_WIN
endif

DEFINES := \
	-DAPP_NAME=\"$(APP_NAME)\" \
	-DAPP_VERSION=\"$(APP_VERSION)\" \
	-DAPP_LIB_DIR=\"$(APP_LIB_DIR)\" \
	-DTTY_PREFIX=\"$(TTY_PREFIX)\"

ifdef DEBUG
 CFLAGS += -g
endif

.PHONY: all
all: $(NAME)

$(NAME): $(SOURCES) $(HEADERS)
	$(CC) $(CFLAGS) $(DEFINES) $(SOURCES) $(LDLIBS) -o $(@)

install: $(NAME) $(CLIENT_LOADERS) $(LIB_OTHER) $(DOCS)
	mkdir -p $(APP_LIB_DIR)
	for s in $(CLIENT_LOADERS) ;do \
		d=$(APP_LIB_DIR)/$${s##*/} ; \
		install $(INSTALLOWNER) -m 0644 $${s} $${d} ; \
		[ ! -f $${s}.pre-install.txt ] && continue ;install $(INSTALLOWNER) -m 0644 $${s}.pre-install.txt $${d}.pre-install.txt ; \
		[ ! -f $${s}.post-install.txt ] && continue ;install $(INSTALLOWNER) -m 0644 $${s}.post-install.txt $${d}.post-install.txt ; \
	done
	for s in $(LIB_OTHER) ;do \
		d=$(APP_LIB_DIR)/$${s##*/} ; \
		install $(INSTALLOWNER) -m 0644 $${s} $${d} ; \
	done
	for s in $(DOCS) ;do \
		d=$(APP_DOC_DIR)/$${s} ; \
		mkdir -p $${d%/*} ; \
		install $(INSTALLOWNER) -m 0644 $${s} $${d} ; \
	done
	mkdir -p $(PREFIX)/bin
	install $(INSTALLOWNER) -m 0755 $(NAME) $(PREFIX)/bin/$(NAME)
	install $(INSTALLOWNER) -m 0755 co2ba.sh $(PREFIX)/bin/co2ba

uninstall:
	rm -rf $(APP_LIB_DIR) $(APP_DOC_DIR) $(PREFIX)/bin/$(NAME) $(PREFIX)/bin/co2ba

clean:
	rm -f $(NAME)
