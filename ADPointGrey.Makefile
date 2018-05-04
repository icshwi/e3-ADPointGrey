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
# Please look at many other _module_.Makefile in e3-* repository
# 


where_am_I := $(dir $(abspath $(lastword $(MAKEFILE_LIST))))

include $(E3_REQUIRE_TOOLS)/driver.makefile

ifneq ($(strip $(ASYN_DEP_VERSION)),)
asyn_VERSION=$(ASYN_DEP_VERSION)
endif

ifneq ($(strip $(ADCORE_DEP_VERSION)),)
ADCore_VERSION=$(ADCORE_DEP_VERSION)
endif


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



# We don't have LIB_INSTALLS, so will tackle later
ifeq (linux-x86_64, $(findstring linux-x86_64, $(T_A)))
LIB_INSTALLS    += $(SUPPORT)/os/linux-x86_64/libflycapture.so
LIB_INSTALLS    += $(SUPPORT)/os/linux-x86_64/libflycapture.so.2
LIB_INSTALLS    += $(SUPPORT)/os/linux-x86_64/libflycapture.so.2.8.3.1
endif






TEMPLATES += $(APPDB)/pointGrey.template
TEMPLATES += $(APPDB)/pointGreyProperty.template
TEMPLATES += $(APPDB)/pointGreyGigEProperty.template

# db rule is the default in RULES_E3, so add the empty one

db:
