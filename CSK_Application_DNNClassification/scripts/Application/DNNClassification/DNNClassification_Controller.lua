---@diagnostic disable: undefined-global, redundant-parameter, missing-parameter

--***************************************************************
-- Inside of this script, you will find the necessary functions,
-- variables and events to communicate with the dnnClassification_Model
--***************************************************************

--**************************************************************************
--************************ Start Global Scope ******************************
--**************************************************************************
local nameOfModule = 'CSK_DNNClassification'

-- Timer to update UI via events after page was loaded
local tmrDNNClassification = Timer.create()
tmrDNNClassification:setExpirationTime(300)
tmrDNNClassification:setPeriodic(false)

-- Reference to global handle
local dnnClassification_Model
local forwardFunctions = {}

-- ************************ UI Events Start ********************************

Script.serveEvent("CSK_DNNClassification.OnNewStatusLoadParameterOnReboot", "DNNClassification_OnNewStatusLoadParameterOnReboot")
Script.serveEvent("CSK_DNNClassification.OnPersistentDataModuleAvailable", "DNNClassification_OnPersistentDataModuleAvailable")
Script.serveEvent("CSK_DNNClassification.OnNewParameterName", "DNNClassification_OnNewParameterName")
Script.serveEvent("CSK_DNNClassification.OnDataLoadedOnReboot", "DNNClassification_OnDataLoadedOnReboot")
Script.serveEvent('CSK_DNNClassification.OnNewStatusOfflineMode', 'DNNClassification_OnNewStatusOfflineMode')
Script.serveEvent('CSK_DNNClassification.OnNewStatusStoreOnFTP', 'DNNClassification_OnNewStatusStoreOnFTP')

Script.serveEvent('CSK_DNNClassification.OnUserLevelOperatorActive', 'DNNClassification_OnUserLevelOperatorActive')
Script.serveEvent('CSK_DNNClassification.OnUserLevelMaintenanceActive', 'DNNClassification_OnUserLevelMaintenanceActive')
Script.serveEvent('CSK_DNNClassification.OnUserLevelServiceActive', 'DNNClassification_OnUserLevelServiceActive')
Script.serveEvent('CSK_DNNClassification.OnUserLevelAdminActive', 'DNNClassification_OnUserLevelAdminActive')

-- ************************ UI Events End **********************************

--**************************************************************************
--********************** End Global Scope **********************************
--**************************************************************************
--**********************Start Function Scope *******************************
--**************************************************************************

--- Function to react on status change of Operator user level
---@param status boolean Status if Operator level is active
local function handleOnUserLevelOperatorActive(status)
  Script.notifyEvent("DNNClassification_OnUserLevelOperatorActive", status)
end

--- Function to react on status change of Maintenance user level
---@param status boolean Status if Maintenance level is active
local function handleOnUserLevelMaintenanceActive(status)
  Script.notifyEvent("DNNClassification_OnUserLevelMaintenanceActive", status)
end

--- Function to react on status change of Service user level
---@param status boolean Status if Service level is active
local function handleOnUserLevelServiceActive(status)
  Script.notifyEvent("DNNClassification_OnUserLevelServiceActive", status)
end

--- Function to react on status change of Admin user level
---@param status boolean Status if Admin level is active
local function handleOnUserLevelAdminActive(status)
  Script.notifyEvent("DNNClassification_OnUserLevelAdminActive", status)
end

--- Function to get access to the dnnClassification_Model object
---@param handle handle Handle of dnnClassification_Model object
local function setDNNClassification_Model_Handle(handle)
  dnnClassification_Model = handle
  if dnnClassification_Model.userManagementModuleAvailable then
    -- Register on events of CSK_UserManagement module if available
    Script.register('CSK_UserManagement.OnUserLevelOperatorActive', handleOnUserLevelOperatorActive)
    Script.register('CSK_UserManagement.OnUserLevelMaintenanceActive', handleOnUserLevelMaintenanceActive)
    Script.register('CSK_UserManagement.OnUserLevelServiceActive', handleOnUserLevelServiceActive)
    Script.register('CSK_UserManagement.OnUserLevelAdminActive', handleOnUserLevelAdminActive)
  end
  Script.releaseObject(handle)
end

--- Function to update user levels
local function updateUserLevel()
  if dnnClassification_Model.userManagementModuleAvailable then
    -- Trigger CSK_UserManagement module to provide events regarding user role
    CSK_UserManagement.pageCalled()
  else
    -- If CSK_UserManagement is not active, show everything
    Script.notifyEvent("DNNClassification_OnUserLevelAdminActive", true)
    Script.notifyEvent("DNNClassification_OnUserLevelMaintenanceActive", true)
    Script.notifyEvent("DNNClassification_OnUserLevelServiceActive", true)
    Script.notifyEvent("DNNClassification_OnUserLevelOperatorActive", true)
  end
end

--- Function to send all relevant values to UI on resume
local function handleOnExpiredTmrDNNClassification()

  updateUserLevel()

  Script.notifyEvent("DNNClassification_OnNewStatusOfflineMode", dnnClassification_Model.offlineMode)
  Script.notifyEvent("DNNClassification_OnNewStatusStoreOnFTP", dnnClassification_Model.parameters.sendToFTP)

  Script.notifyEvent("DNNClassification_OnNewStatusLoadParameterOnReboot", dnnClassification_Model.parameterLoadOnReboot)
  Script.notifyEvent("DNNClassification_OnPersistentDataModuleAvailable", dnnClassification_Model.persistentModuleAvailable)
  Script.notifyEvent("DNNClassification_OnNewParameterName", dnnClassification_Model.parametersName)
end
Timer.register(tmrDNNClassification, "OnExpired", handleOnExpiredTmrDNNClassification)

-- ********************* UI Setting / Submit Functions Start ********************

local function pageCalled()
  updateUserLevel() -- try to hide user specific content asap
  tmrDNNClassification:start()
  return ''
end
Script.serveFunction("CSK_DNNClassification.pageCalled", pageCalled)

local function setOfflineImageMode(status)
  _G.logger:info(nameOfModule .. ": Set offline image mode to:" .. tostring(status))
  dnnClassification_Model.offlineMode = status
  if status == false then
    -- Try to register to related camera
    CSK_MultiDeepLearning.setRegisterEvent('CSK_MultiRemoteCamera.OnNewImageCamera' .. tostring(dnnClassification_Model.selectedDLInstance))
  else
    -- Register to offline image player
    CSK_MultiDeepLearning.setRegisterEvent('CSK_ImagePlayer.OnNewImage')
  end
  Script.notifyEvent("DNNClassification_OnNewStatusOfflineMode", dnnClassification_Model.offlineMode)
  CSK_MultiDeepLearning.pageCalled()
end
Script.serveFunction('CSK_DNNClassification.setOfflineImageMode', setOfflineImageMode)

--- Function to forward incoming images via FTP
---@param result bool Result of DNN
---@param class string Class of DNN
---@param score float Score of DNN
---@param image Image Image
---@param source string Instance source
local function handleOnNewImageCamera(result, class, score, image, source)
  local day, month, year, hour, minute, second, ms = DateTime.getDateTimeValuesLocal()
  local dateString = string.format('%s_%s_%s_%s_%s_%s_%s', year, month, day, hour, minute, second, ms)
  CSK_FTPClient.sendImage(image, source .. '_' .. dateString .. '_' .. tostring(result) .. '_' .. class .. '_' .. string.format('%0.1f', score))
end

local function setFTPTransfer(status)
  _G.logger:info(nameOfModule .. ": Set FTP transfer to:" .. tostring(status))
  dnnClassification_Model.parameters.sendToFTP = status
  local instanceAmount = CSK_MultiRemoteCamera.getInstancesAmount()

  if status then
    for i=1, instanceAmount do
      CSK_MultiDeepLearning.setInstance(i)
      CSK_MultiDeepLearning.setForwardImage(true)
      local function tempFunction(result, class, score, image)
        handleOnNewImageCamera(result, class, score, image, 'Instance' .. tostring(i))
      end
      table.insert(forwardFunctions, tempFunction)
      Script.register('CSK_MultiDeepLearning.OnNewFullResultWithImage'..tostring(i), forwardFunctions[#forwardFunctions])
    end
  else
    for j=1, instanceAmount do
      CSK_MultiDeepLearning.setInstance(j)
      CSK_MultiDeepLearning.setForwardImage(false)
    end
    for i=1, #forwardFunctions do
      Script.deregister('CSK_MultiDeepLearning.OnNewFullResultWithImage'..tostring(i), forwardFunctions[i])
    end
    Script.releaseObject(forwardFunctions)
    forwardFunctions = {}
  end
  CSK_MultiDeepLearning.pageCalled()
end
Script.serveFunction('CSK_DNNClassification.setFTPTransfer', setFTPTransfer)

local function setDefaultSetup()

  _G.logger:info(nameOfModule .. ": Configure default setup.")
  if not File.isdir('/public/images') then
    File.mkdir('/public/images')
  end
  File.copy('/resources/CSK_Application_DNNClassification/images/cornflakes', '/public/images/cornflakes')

  if not File.isdir('/public/models') then
    File.mkdir('/public/models')
  end
  File.copy('/resources/CSK_Application_DNNClassification/model/Cornflakes.json', '/public/models/Cornflakes.json')

  CSK_MultiDeepLearning.setModelByName('Cornflakes.json')
  CSK_ImagePlayer.setPath('/public/images/cornflakes')
  CSK_ImagePlayer.setImageType('bmp')
  setOfflineImageMode(true)
  CSK_MultiDeepLearning.setViewerActive(true)
  CSK_ImagePlayer.startProvider()
  CSK_MultiDeepLearning.pageCalled()
end
Script.serveFunction('CSK_DNNClassification.setDefaultSetup', setDefaultSetup)

-- *****************************************************************
-- Following function can be adapted for CSK_PersistentData module usage
-- *****************************************************************

local function setParameterName(name)
  _G.logger:info(nameOfModule .. ": Set parameter name: " .. tostring(name))
  dnnClassification_Model.parametersName = name
end
Script.serveFunction("CSK_DNNClassification.setParameterName", setParameterName)

local function sendParameters()
  if dnnClassification_Model.persistentModuleAvailable then
    CSK_PersistentData.addParameter(dnnClassification_Model.helperFuncs.convertTable2Container(dnnClassification_Model.parameters), dnnClassification_Model.parametersName)
    CSK_PersistentData.setModuleParameterName(nameOfModule, dnnClassification_Model.parametersName, dnnClassification_Model.parameterLoadOnReboot)
    _G.logger:info(nameOfModule .. ": Send DNNClassification parameters with name '" .. dnnClassification_Model.parametersName .. "' to CSK_PersistentData module.")
    CSK_PersistentData.saveData()
  else
    _G.logger:warning(nameOfModule .. ": CSK_PersistentData Module not available.")
  end
end
Script.serveFunction("CSK_DNNClassification.sendParameters", sendParameters)

local function loadParameters()
  if dnnClassification_Model.persistentModuleAvailable then
    local data = CSK_PersistentData.getParameter(dnnClassification_Model.parametersName)
    if data then
      _G.logger:info(nameOfModule .. ": Loaded parameters from CSK_PersistentData module.")
      dnnClassification_Model.parameters = dnnClassification_Model.helperFuncs.convertContainer2Table(data)
      -- If something needs to be configured/activated with new loaded data, place this here:
      setFTPTransfer(dnnClassification_Model.parameters.sendToFTP)

      CSK_DNNClassification.pageCalled()
    else
      _G.logger:warning(nameOfModule .. ": Loading parameters from CSK_PersistentData module did not work.")
    end
  else
    _G.logger:warning(nameOfModule .. ": CSK_PersistentData module not available.")
  end
end
Script.serveFunction("CSK_DNNClassification.loadParameters", loadParameters)

local function setLoadOnReboot(status)
  dnnClassification_Model.parameterLoadOnReboot = status
  _G.logger:info(nameOfModule .. ": Set new status to load setting on reboot: " .. tostring(status))
end
Script.serveFunction("CSK_DNNClassification.setLoadOnReboot", setLoadOnReboot)

--- Function to react on initial load of persistent parameters
local function handleOnInitialDataLoaded()

  if string.sub(CSK_PersistentData.getVersion(), 1, 1) == '1' then

    _G.logger:warning(nameOfModule .. ': CSK_PersistentData module is too old and will not work. Please update CSK_PersistentData module.')

    dnnClassification_Model.persistentModuleAvailable = false
  else

    local parameterName, loadOnReboot = CSK_PersistentData.getModuleParameterName(nameOfModule)

    if parameterName then
      dnnClassification_Model.parametersName = parameterName
      dnnClassification_Model.parameterLoadOnReboot = loadOnReboot
    end

    if dnnClassification_Model.parameterLoadOnReboot then
      loadParameters()
    end
    Script.notifyEvent('DNNClassification_OnDataLoadedOnReboot')
  end
end
Script.register("CSK_PersistentData.OnInitialDataLoaded", handleOnInitialDataLoaded)

-- *************************************************
-- END of functions for CSK_PersistentData module usage
-- *************************************************

return setDNNClassification_Model_Handle

--**************************************************************************
--**********************End Function Scope *********************************
--**************************************************************************

