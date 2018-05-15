

epicsEnvSet("TOP",${PWD})

< ${TOP}/cmds/load_libs.cmd


#dlload /home/utgard/e3/e3-ADPointGrey/ADPointGrey/pointGreySupport/os/linux-x86_64/libflycapture.so 

require ADPointGrey,2.6.0



epicsEnvSet("EPICS_CA_MAX_ARRAY_BYTES","64000000")

### The port name for the detector
epicsEnvSet("PORT1",   "PG1")
### Really large queue so we can stream to disk at full camera speed
epicsEnvSet("QSIZE",  "2000")   
### The maximim image width; used for row profiles in the NDPluginStats plugin
epicsEnvSet("XSIZE",  "1536")
### The maximim image height; used for column profiles in the NDPluginStats plugin
epicsEnvSet("YSIZE",  "2048")
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
epicsEnvSet("CAMERA_ID1", "17170681")
epicsEnvSet("PREFIX1", "PG1:")
#pointGreyConfig("PG1", $(CAMERA_ID1), 0x1, 0)
asynSetTraceIOMask(PG1, 0, 2)
###asynSetTraceMask($(PORT), 0, 0xFF)
###asynSetTraceFile($(PORT), 0, "asynTrace.out")
###asynSetTraceInfoMask($(PORT), 0, 0xf)

dbLoadRecords("pointGrey.db", "P=$(PREFIX1),R=cam1:,PORT=PG1,ADDR=0,TIMEOUT=1")
dbLoadRecords("pointGreyPG1-ess.db")

### Create a standard arrays plugin
NDStdArraysConfigure("Image1", 5, 0, "PG1", 0, 0)
### Use this line for 8-bit data only
###dbLoadRecords("$(ADCORE)/db/NDStdArrays.template", "P=$(PREFIX),R=image1:,PORT=Image1,ADDR=0,TIMEOUT=1,NDARRAY_PORT=$(PORT),TYPE=Int8,FTVL=CHAR,NELEMENTS=$(NELEMENTS)")
### Use this line for 8-bit or 16-bit data
dbLoadRecords("NDStdArrays.template", "P=$(PREFIX1),R=image1:,PORT=Image1,ADDR=0,TIMEOUT=1,NDARRAY_PORT=PG1,TYPE=Int16,FTVL=SHORT,NELEMENTS=$(NELEMENTS)")

### Load all other plugins using commonPlugins.cmd
#< $(ADCORE)/iocBoot/commonPlugins.cmd
#set_requestfile_path("$(ADPOINTGREY)/pointGreyApp/Db")

iocshCmd Example_commonPlugins.cmd
#set_requestfile_path("$(ADPOINTGREY)/pointGreyApp/Db")


iocInit()

### save things every thirty seconds
#create_monitor_set("auto_settings.req", 30,"P=$(PREFIX)")

### Wait for enum callbacks to complete
epicsThreadSleep(1.0)

### Records with dynamic enums need to be processed again because the enum values are not available during iocInit.  
dbpf("$(PREFIX1)cam1:Format7Mode.PROC", "1")
dbpf("$(PREFIX1)cam1:PixelFormat.PROC", "1")

dbpf("$(PREFIX2)cam1:Format7Mode.PROC", "1")
dbpf("$(PREFIX2)cam1:PixelFormat.PROC", "1")
### Wait for callbacks on the property limits (DRVL, DRVH) to complete
epicsThreadSleep(1.0)

### Records that depend on the state of the dynamic enum records or property limits also need to be processed again
### Other property records may need to be added to this list
dbpf("$(PREFIX1)cam1:FrameRate.PROC", "1")
dbpf("$(PREFIX1)cam1:FrameRateValAbs.PROC", "1")
dbpf("$(PREFIX1)cam1:AcquireTime.PROC", "1")
dbpf("$(PREFIX1)cam1:FrameRateValAbs_RBV", "3");


