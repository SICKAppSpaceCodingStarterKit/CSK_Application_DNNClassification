---@diagnostic disable: undefined-global, redundant-parameter, missing-parameter

-- Load all relevant APIs for this module
--**************************************************************************

local availableAPIs = {}

local function loadAPIs()
  CSK_DNNClassification = require 'API.CSK_DNNClassification'

  Container = require 'API.Container'
  DateTime = require 'API.DateTime'
  Engine = require 'API.Engine'
  File = require 'API.File'
  Log = require 'API.Log'
  Log.Handler = require 'API.Log.Handler'
  Log.SharedLogger = require 'API.Log.SharedLogger'
  Object = require 'API.Object'
  Parameters = require 'API.Parameters'
  Timer = require 'API.Timer'
  View = require 'API.View'

  CSK_Logger = require 'API.CSK_Logger'
  CSK_DateTime = require 'API.CSK_DateTime'
  CSK_DeviceScanner = require 'API.CSK_DeviceScanner'
  CSK_FTPClient = require 'API.CSK_FTPClient'
  CSK_ImagePlayer = require 'API.CSK_ImagePlayer'
  CSK_MultiDeepLearning = require 'API.CSK_MultiDeepLearning'
  CSK_MultiRemoteCamera = require 'API.CSK_MultiRemoteCamera'
  CSK_PersistentData = require 'API.CSK_PersistentData'
  CSK_PowerManager = require 'API.CSK_PowerManager'

  -- Check if related CSK modules are available to be used
  local appList = Engine.listApps()
  for i = 1, #appList do
    if appList[i] == 'CSK_Module_PersistentData' then
      CSK_PersistentData = require 'API.CSK_PersistentData'
    elseif appList[i] == 'CSK_Module_UserManagement' then
      CSK_UserManagement = require 'API.CSK_UserManagement'
    end
  end
end

local function loadSpecificAPIs()
  -- If you want to check for specific APIs/functions supported on the device the module is running, place relevant APIs here
  -- e.g.:
  -- NTPClient = require 'API.NTPClient'
end

availableAPIs.default = xpcall(loadAPIs, debug.traceback) -- TRUE if all default APIs were loaded correctly
--availableAPIs.specific = xpcall(loadSpecificAPIs, debug.traceback) -- TRUE if all specific APIs were loaded correctly

return availableAPIs
--**************************************************************************