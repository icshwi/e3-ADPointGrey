require ADPointGrey,2.6.0
require busy,1.7.0
#require sequencer,2.1.21
#require sscan,1339922
#require calc,3.7.1
#require autosave,5.9.0


epicsEnvSet("CMD_TOP", "$(E3_CMD_TOP)")
epicsEnvSet("IOC", "iocPointGrey")

epicsEnvSet("EPICS_CA_MAX_ARRAY_BYTES","64000000")

# The port name for the detector
epicsEnvSet("PORT",   "PG1")
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

# Serial Number 
epicsEnvSet("CAMERA_ID", "18347569")
epicsEnvSet("PREFIX", "PG1:")

# pointGreyConfig(const char *portName, int cameraId, int traceMask, int memoryChannel,
#                 int maxBuffers, size_t maxMemory, int priority, int stackSize)
pointGreyConfig("$(PORT)", $(CAMERA_ID), 0x1, 0)
asynSetTraceIOMask($(PORT), 0, 2)
#asynSetTraceMask($(PORT), 0, 0xFF)
#asynSetTraceFile($(PORT), 0, "asynTrace.out")
#asynSetTraceInfoMask($(PORT), 0, 0xf)



dbLoadRecords("pointGrey.db", "P=$(PREFIX),R=cam1:,PORT=$(PORT),ADDR=0,TIMEOUT=1")
dbLoadTemplate("pointGrey.substitutions")


# Create a standard arrays plugin
NDStdArraysConfigure("Image1", 5, 0, "$(PORT)", 0, 0)
# Use this line for 8-bit data only
#dbLoadRecords("$(ADCORE)/db/NDStdArrays.template", "P=$(PREFIX),R=image1:,PORT=Image1,ADDR=0,TIMEOUT=1,NDARRAY_PORT=$(PORT),TYPE=Int8,FTVL=CHAR,NELEMENTS=$(NELEMENTS)")
# Use this line for 8-bit or 16-bit data
dbLoadRecords("NDStdArrays.template", "P=$(PREFIX),R=image1:,PORT=Image1,ADDR=0,TIMEOUT=1,NDARRAY_PORT=$(PORT),TYPE=Int16,FTVL=SHORT,NELEMENTS=$(NELEMENTS)")


# Load all other plugins using commonPlugins.cmd
< $(CMD_TOP)/bf23mpc_commonPlugins.cmd

iocInit()


# Wait for enum callbacks to complete
epicsThreadSleep(1.0)

# Records with dynamic enums need to be processed again because the enum values are not available during iocInit.  
dbpf("$(PREFIX)cam1:Format7Mode.PROC", "1")
dbpf("$(PREFIX)cam1:PixelFormat.PROC", "1")

# Wait for callbacks on the property limits (DRVL, DRVH) to complete
epicsThreadSleep(1.0)

# Records that depend on the state of the dynamic enum records or property limits also need to be processed again
# Other property records may need to be added to this list
dbpf("$(PREFIX)cam1:FrameRate.PROC", "1")
dbpf("$(PREFIX)cam1:FrameRateValAbs.PROC", "1")
dbpf("$(PREFIX)cam1:AcquireTime.PROC", "1")
