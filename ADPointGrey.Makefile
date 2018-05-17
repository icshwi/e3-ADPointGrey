#
#  Copyright (c) 2017 - Present  European Spallation Source ERIC
#
#  The program is free software: you can redistribute
#  it and/or modify it under the terms of the GNU General Public License
#  as published by the Free Software Foundation, either version 2 of the
#  License, or any newer version.
#
#  This program is distributed in the hope that it will be useful, but WITHOUT
#  ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
#  FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for
#  more details.
#
#  You should have received a copy of the GNU General Public License along with
#  this program. If not, see https://www.gnu.org/licenses/gpl-2.0.txt
#
# 
# Author  : Jeong Han Lee
# email   : jeonghan.lee@gmail.com
# Date    : Tuesday, April 17 00:11:32 CEST 2018
# version : 0.0.1 
#



where_am_I := $(dir $(abspath $(lastword $(MAKEFILE_LIST))))

include $(E3_REQUIRE_TOOLS)/driver.makefile

ifneq ($(strip $(ASYN_DEP_VERSION)),)
asyn_VERSION=$(ASYN_DEP_VERSION)
endif

ifneq ($(strip $(ADCORE_DEP_VERSION)),)
ADCore_VERSION=$(ADCORE_DEP_VERSION)
endif

# Exclude linux-ppc64e6500
EXCLUDE_ARCHS = linux-ppc64e6500

SUPPORT:=pointGreySupport

APP:=pointGreyApp
APPDB:=$(APP)/Db
APPSRC:=$(APP)/src


## We will use XML2 as the system lib, instead of ADSupport
## Do we need to load libxml2 when we start iocsh?

USR_INCLUDES += -I/usr/include/libxml2
LIB_SYS_LIBS += xml2	


# https://gcc.gnu.org/wiki/FAQ#Wnarrowing
# https://gcc.gnu.org/bugzilla/show_bug.cgi?id=55783
# -std=c++11 
USR_CXXFLAGS += -Wno-narrowing


DBDS += $(APPSRC)/pointGreySupport.dbd


SOURCES += $(APPSRC)/pointGrey.cpp

## PointGreySupport
HEADERS += $(SUPPORT)/AVIRecorder.h
HEADERS += $(SUPPORT)/BusManager.h
HEADERS += $(SUPPORT)/Camera.h
HEADERS += $(SUPPORT)/CameraBase.h
HEADERS += $(SUPPORT)/Error.h
HEADERS += $(SUPPORT)/FlyCapture2.h
HEADERS += $(SUPPORT)/FlyCapture2Defs.h
HEADERS += $(SUPPORT)/FlyCapture2Platform.h
HEADERS += $(SUPPORT)/GigECamera.h
HEADERS += $(SUPPORT)/Image.h
HEADERS += $(SUPPORT)/ImageStatistics.h
HEADERS += $(SUPPORT)/TopologyNode.h
HEADERS += $(SUPPORT)/Utilities.h



# # We don't have LIB_INSTALLS, so will tackle later
# #ifeq (linux-x86_64, $(findstring linux-x86_64, $(T_A)))
ifeq ($(T_A),linux-x86_64)
USR_LDFLAGS += -Wl,--enable-new-dtags
USR_LDFLAGS += -Wl,-rpath=$(E3_MODULES_VENDOR_LIBS_LOCATION)
USR_LDFLAGS += -L$(E3_MODULES_VENDOR_LIBS_LOCATION)
USR_LDFLAGS += -lflycapture
endif

# According to its makefile
VENDOR_LIBS += $(SUPPORT)/os/linux-x86_64/libflycapture.so.2.8.3.1
VENDOR_LIBS += $(SUPPORT)/os/linux-x86_64/libflycapture.so.2
VENDOR_LIBS += $(SUPPORT)/os/linux-x86_64/libflycapture.so


#SCRIPTS += startup.cmd

# We have to convert all to db 
TEMPLATES += $(wildcard $(APPDB)/*.db)

# TEMPLATES += $(APPDB)/pointGrey.template
# TEMPLATES += $(APPDB)/pointGreyProperty.template
# TEMPLATES += $(APPDB)/pointGreyGigEProperty.template


## This RULE should be used in case of inflating DB files 
## db rule is the default in RULES_DB, so add the empty one
## Please look at e3-mrfioc2 for example.

EPICS_BASE_HOST_BIN = $(EPICS_BASE)/bin/$(EPICS_HOST_ARCH)
MSI = $(EPICS_BASE_HOST_BIN)/msi

USR_DBFLAGS += -I . -I ..
USR_DBFLAGS += -I $(EPICS_BASE)/db
USR_DBFLAGS += -I $(APPDB)

# pointGrey.template includes ADCore.template
#
USR_DBFLAGS += -I $(E3_SITELIBS_PATH)/ADCore_$(ADCORE_DEP_VERSION)_db

SUBS=$(wildcard $(APPDB)/*.substitutions)
TMPS=$(wildcard $(APPDB)/*.template)

db: $(SUBS) $(TMPS)

$(SUBS):
	@printf "Inflating database ... %44s >>> %40s \n" "$@" "$(basename $(@)).db"
	@rm -f  $(basename $(@)).db.d  $(basename $(@)).db
	@$(MSI) -D $(USR_DBFLAGS) -o $(basename $(@)).db -S $@  > $(basename $(@)).db.d
	@$(MSI)    $(USR_DBFLAGS) -o $(basename $(@)).db -S $@

$(TMPS):
	@printf "Inflating database ... %44s >>> %40s \n" "$@" "$(basename $(@)).db"
	@rm -f  $(basename $(@)).db.d  $(basename $(@)).db
	@$(MSI) -D $(USR_DBFLAGS) -o $(basename $(@)).db $@  > $(basename $(@)).db.d
	@$(MSI)    $(USR_DBFLAGS) -o $(basename $(@)).db $@


.PHONY: db $(SUBS) $(TMPS)


# Overwrite
# RULES_VLIBS
# CONFIG_E3
vlibs: $(VENDOR_LIBS)

$(VENDOR_LIBS):
	$(QUIET) $(SUDO) install -m 755 -d $(E3_MODULES_VENDOR_LIBS_LOCATION)/
	$(QUIET) $(SUDO) install -m 644 $@ $(E3_MODULES_VENDOR_LIBS_LOCATION)/

.PHONY: $(VENDOR_LIBS) vlibs
