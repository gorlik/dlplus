# Makefile for DeskLink+

OS ?= $(shell uname)
CC ?= gcc
CFLAGS += -O2 -Wall
#CFLAGS += -std=c99 -D_DEFAULT_SOURCE    # prove the code is still plain c
PREFIX ?= /usr/local
APP_NAME := dl
APP_LIB_DIR := $(PREFIX)/lib/$(APP_NAME)
APP_DOC_DIR := $(PREFIX)/share/doc/$(APP_NAME)
APP_VERSION := $(shell git describe --long 2>&-)

CLIENT_LOADERS := \
	clients/teeny/TINY.100 \
	clients/teeny/D_WEENY.100 \
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
	clients/disk_power/Disk_Power.txt \
#	clients/power-dos/powr-d.txt

DOCS := dl.do README.txt README.md LICENSE $(CLIENT_DOCS)
SOURCES := dl.c dir_list.c
HEADERS := dir_list.h constants.h

ifeq ($(OS),Darwin)
 #DEFAULT_CLIENT_TTY := cu.*
else
 ifneq (,$(findstring BSD,$(OS)))
  DEFAULT_CLIENT_TTY := ttyU0
 else ifeq ($(OS),Linux)
  DEFAULT_CLIENT_TTY := ttyUSB0
 else
  DEFAULT_CLIENT_TTY := ttyS0
 endif
 LDLIBS += -lutil
endif

INSTALLOWNER = -o root
ifeq ($(OS),Windows_NT)
 INSTALLOWNER =
 CFLAGS += -D_WIN
endif

DEFINES := \
	-DAPP_VERSION=\"$(APP_VERSION)\" \
	-DAPP_LIB_DIR=\"$(APP_LIB_DIR)\" \
	-DDEFAULT_CLIENT_TTY=\"$(DEFAULT_CLIENT_TTY)\"

ifdef DEBUG
 CFLAGS += -g
endif

.PHONY: all
all: $(APP_NAME)

$(APP_NAME): $(SOURCES) $(HEADERS)
	$(CC) $(CFLAGS) $(DEFINES) $(SOURCES) $(LDLIBS) -o $(@)

install: $(APP_NAME) $(CLIENT_LOADERS) $(LIB_OTHER) $(DOCS)
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
	install $(INSTALLOWNER) -m 0755 $(APP_NAME) $(PREFIX)/bin/$(APP_NAME)
	install $(INSTALLOWNER) -m 0755 co2ba.sh $(PREFIX)/bin/co2ba

uninstall:
	rm -rf $(APP_LIB_DIR) $(APP_DOC_DIR) $(PREFIX)/bin/$(APP_NAME) $(PREFIX)/bin/co2ba

clean:
	rm -f $(APP_NAME)
