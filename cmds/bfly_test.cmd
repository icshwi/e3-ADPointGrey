require ADPointGrey,2.7.0
require busy,1.7.0
require sequencer,2.2.6
#require sscan,1339922
require calc,3.7.1
#require autosave,5.9.0


## This is the e3 startup script for the following camera :
##
## Serial number:       18347569
## Camera model:        Blackfly BFLY-PGE-23S6C
## Camera vendor:       Point Grey Research
## Sensor:              Sony IMX249 (1/1.2" Color CMOS)
## Resolution:          1920x1200
## Firmware version:    1.66.3.0
## Firmware build time: Thu Oct 19 23:02:18 2017


epicsEnvSet("TOP", "$(E3_CMD_TOP)/..")
epicsEnvSet("IOC", "BFLY-PGE-23S6C")

epicsEnvSet("EPICS_CA_MAX_ARRAY_BYTES","64000000")

# Really large queue so we can stream to disk at full camera speed
epicsEnvSet("QSIZE",  "2000")   
# The maximim image width; used for row profiles in the NDPluginStats plugin
epicsEnvSet("XSIZE",  "1920")
# The maximim image height; used for column profiles in the NDPluginStats plugin
epicsEnvSet("YSIZE",  "1200")
# The maximum number of time series points in the NDPluginStats plugin
epicsEnvSet("NCHANS", "2048")
# The maximum number of frames buffered in the NDPluginCircularBuff plugin
epicsEnvSet("CBUFFS", "500")

# Define NELEMENTS to be enough for a XSIZE X YSIZEx3 (color) image
# XSIZE X YSIZE X 3 (color) X 1 (one camera) = 6912 k
epicsEnvSet("NELEMENTS", "6912000")

epicsEnvSet("UNIT",  "1")
# The port name for the detector
epicsEnvSet("PORT",   "BFLY-PG$(UNIT)")
epicsEnvSet("PREF",   "$(PORT):")
epicsEnvSet("RRRR",   "cam$(UNIT):")
# Serial Number 
epicsEnvSet("CAMERA_ID", "18347569")


# pointGreyConfig(const char *portName, int cameraId, int traceMask, int memoryChannel,
#                 int maxBuffers, size_t maxMemory, int priority, int stackSize)
pointGreyConfig("$(PORT)", $(CAMERA_ID), 0x1, 0)
asynSetTraceIOMask($(PORT), 0, 2)

dbLoadRecords("pointGrey.db", "P=$(PREF),R=$(RRRR),PORT=$(PORT),ADDR=0,TIMEOUT=1")
dbLoadRecords("pointGreyPG-ess.db", "P=$(PREF),R=$(RRRR),PORT=$(PORT)" )


NDStdArraysConfigure("Image$(UNIT)", 5, 0, "$(PORT)", 0, 0)
dbLoadRecords("NDStdArrays.template", "P=$(PREF),R=image$(UNIT):,PORT=Image$(UNIT),ADDR=0,TIMEOUT=1,NDARRAY_PORT=$(PORT),TYPE=Int16,FTVL=SHORT,NELEMENTS=$(NELEMENTS)")


## Modified ADCore commonPlugins in order to use the different UNIT number
## 
iocshLoad("$(ADCore_DIR)/adCommPlugins.iocsh", "PREFIX=$(PREF),UNIT=$(UNIT),PORT=$(PORT),QSIZE=$(QSIZE),XSIZE=$(XSIZE),YSIZE=$(YSIZE),NCHANS=$(XSIZE),CBUFFS=$(CBUFFS)")


iocInit()



dbl > "$(TOP)/$(IOC)_PVs.list"

# Wait for enum callbacks to complete
epicsThreadSleep(1.0)


# Records with dynamic enums need to be processed again because the enum values are not available during iocInit.  
dbpf("$(PREF)$(RRRR)Format7Mode.PROC", "1")
dbpf("$(PREF)$(RRRR)PixelFormat.PROC", "1")

# Wait for callbacks on the property limits (DRVL, DRVH) to complete
epicsThreadSleep(1.0)

# Records that depend on the state of the dynamic enum records or property limits also need to be processed again
# Other property records may need to be added to this list
dbpf("$(PREF)$(RRRR)FrameRate.PROC", "1")
dbpf("$(PREF)$(RRRR)FrameRateValAbs.PROC", "1")
dbpf("$(PREF)$(RRRR)AcquireTime.PROC", "1")



