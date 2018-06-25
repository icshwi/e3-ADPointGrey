#require ADPointGrey,2.6.0
require ADPointGrey,develop
require ADPluginEdge,develop
require busy,1.7.0
require sequencer,2.1.21
require sscan,1339922
require calc,3.7.0
require autosave,5.9.0

epicsEnvSet("IOC","iocPointGrey")
epicsEnvSet("TOP",".")
epicsEnvSet("ADPOINTGREY","/home/iocuser/e3/e3-ADPointGrey/ADPointGrey")
# epicsEnvSet("ADPOINTGREY","/home/utgard/epics_env/epics-modules/areaDetector/ADPointGrey/iocs/pointGreyIOC/../..")
epicsEnvSet("ADPLUGINEDGE","/home/iocuser/e3/e3-ADPluginEdge/ADPluginEdge-dev")
# epicsEnvSet("AREA_DETECTOR","/home/utgard/epics_env/epics-modules/areaDetector")
# epicsEnvSet("EPICS_BASE","/home/utgard/epics_env/epics-base")
# epicsEnvSet("EPICS_MODULES","/home/utgard/epics_env/epics-modules")
# epicsEnvSet("ASYN","/home/utgard/epics_env/epics-modules/asyn")
# epicsEnvSet("ADSUPPORT","/home/utgard/epics_env/epics-modules/areaDetector/ADSupport")
# epicsEnvSet("ADCORE","/home/utgard/epics_env/epics-modules/areaDetector/ADCore")
epicsEnvSet("ADCORE","/home/iocuser/e3/e3-ADCore/ADCore")
# epicsEnvSet("AUTOSAVE","/home/utgard/epics_env/epics-modules/autosave")
epicsEnvSet("AUTOSAVE","/home/iocuser/e3/e3-autosave/autosave")
# epicsEnvSet("BUSY","/home/utgard/epics_env/epics-modules/busy")
# epicsEnvSet("CALC","/home/utgard/epics_env/epics-modules/calc")
epicsEnvSet("CALC","/home/iocuser/e3/e3-calc")
# epicsEnvSet("SNCSEQ","/home/utgard/epics_env/epics-modules/seq")
# epicsEnvSet("SSCAN","/home/utgard/epics_env/epics-modules/sscan")



epicsEnvSet("EPICS_CA_MAX_ARRAY_BYTES","64000000")

### The port name for the detector
epicsEnvSet("PORT",   "PG1")
### Really large queue so we can stream to disk at full camera speed
epicsEnvSet("QSIZE",  "2000")   
### The maximim image width; used for row profiles in the NDPluginStats plugin
epicsEnvSet("XSIZE",  "2048")
### The maximim image height; used for column profiles in the NDPluginStats plugin
epicsEnvSet("YSIZE",  "1556")
### The maximum number of time series points in the NDPluginStats plugin
epicsEnvSet("NCHANS", "2048")
### The maximum number of frames buffered in the NDPluginCircularBuff plugin
epicsEnvSet("CBUFFS", "500")
### The search path for database files
# epicsEnvSet("EPICS_DB_INCLUDE_PATH", "$(ADCORE)/db")
### Define NELEMENTS to be enough for a 2048x1536x2x2 (size x 2bytes per pixel x 2 cameras) = 12592912, I set 20000000 memory is not an issue...
epicsEnvSet("NELEMENTS", "12592912")

#########################   camera 1 #######################################################################################################################################
### pointGreyConfig(const char *portName, int cameraId, int traceMask, int memoryChannel,
###                 int maxBuffers, size_t maxMemory, int priority, int stackSize)
epicsEnvSet("CAMERA_ID", "17170681")
epicsEnvSet("PREFIX", "PG1:")
pointGreyConfig("$(PORT)", $(CAMERA_ID), 0x1, 0)
asynSetTraceIOMask($(PORT), 0, 2)
###asynSetTraceMask($(PORT), 0, 0xFF)
###asynSetTraceFile($(PORT), 0, "asynTrace.out")
###asynSetTraceInfoMask($(PORT), 0, 0xf)

dbLoadRecords("pointGrey.db", "P=$(PREFIX),R=cam1:,PORT=$(PORT),ADDR=0,TIMEOUT=1")
dbLoadRecords("pointGreyPG1-ess.db")

### Create a standard arrays plugin
NDStdArraysConfigure("Image1", 5, 0, $(PORT), 0, 0)
### Use this line for 8-bit data only
###dbLoadRecords("$(ADCORE)/db/NDStdArrays.template", "P=$(PREFIX),R=image1:,PORT=Image1,ADDR=0,TIMEOUT=1,NDARRAY_PORT=$(PORT),TYPE=Int8,FTVL=CHAR,NELEMENTS=$(NELEMENTS)")
### Use this line for 8-bit or 16-bit data
dbLoadRecords("NDStdArrays.template", "P=$(PREFIX),R=image1:,PORT=Image1,ADDR=0,TIMEOUT=1,NDARRAY_PORT=$(PORT),TYPE=Int16,FTVL=SHORT,NELEMENTS=$(NELEMENTS)")

### Load all other plugins using commonPlugins.cmd

epicsEnvSet("PREFIX", "${PREFIX}")
epicsEnvSet("PORT"  , "${PORT}")
#< /home/iocuser/e3/e3-ADPointGrey/cmds/adpointgrey_commonPlugins.cmd 
#set_requestfile_path("$(ADPOINTGREY)/pointGreyApp/Db")

#< $(ADCORE)/iocBoot/EXAMPLE_commonPlugins.cmd
< $(ADCORE)/../cmds/commonPlugins.cmd
set_requestfile_path("$(ADPOINTGREY)/pointGreyApp/Db")
set_requestfile_path("$(ADPOINTGREY)/iocs/pointGreyIOC/iocBoot/iocPointGrey")

iocInit()

## save things every thirty seconds
create_monitor_set("auto_settings.req", 30,"P=$(PREFIX)")

## Wait for enum callbacks to complete
epicsThreadSleep(1.0)

## Records with dynamic enums need to be processed again because the enum values are not available during iocInit.  
dbpf("$(PREFIX)cam1:Format7Mode.PROC", "1")
dbpf("$(PREFIX)cam1:PixelFormat.PROC", "1")

## Wait for callbacks on the property limits (DRVL, DRVH) to complete
epicsThreadSleep(1.0)

## Records that depend on the state of the dynamic enum records or property limits also need to be processed again
## Other property records may need to be added to this list
dbpf("$(PREFIX)cam1:FrameRate.PROC", "1")
dbpf("$(PREFIX)cam1:FrameRateValAbs.PROC", "1")
dbpf("$(PREFIX)cam1:AcquireTime.PROC", "1")
dbpf("$(PREFIX)cam1:FrameRateValAbs_RBV", "3");


