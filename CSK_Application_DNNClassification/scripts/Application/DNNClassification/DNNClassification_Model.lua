---@diagnostic disable: undefined-global, redundant-parameter, missing-parameter
--*****************************************************************
-- Inside of this script, you will find the module definition
-- including its parameters and functions
--*****************************************************************

--**************************************************************************
--**********************Start Global Scope *********************************
--**************************************************************************
local nameOfModule = 'CSK_DNNClassification'

local dnnClassification_Model = {}

-- Check if CSK_UserManagement features can be used if wanted
dnnClassification_Model.userManagementModuleAvailable = CSK_UserManagement ~= nil or false

-- Check if CSK_PersistentData features can be used if wanted
dnnClassification_Model.persistentModuleAvailable = CSK_PersistentData ~= nil or false

-- Load script to communicate with the dnnClassification_Model interface and give access
-- to the dnnClassification_Model object.
-- Check / edit this script to see/edit functions which communicate with the UI
local setDNNClassification_ModelHandle = require('Application/DNNClassification/DNNClassification_Controller')
setDNNClassification_ModelHandle(dnnClassification_Model)

--Loading helper functions if needed
dnnClassification_Model.helperFuncs = require('Application/DNNClassification/helper/funcs')

dnnClassification_Model.offlineMode = false -- Status if image source for DeepLearning processing should be offline image player
dnnClassification_Model.selectedDLInstance = 1 -- Selected instance of CSK_MutliDeepLearning module

-- Parameters to be saved permanently if wanted
dnnClassification_Model.parameters = {}
dnnClassification_Model.parameters.sendToFTP = false

-- Default values for persistent data
-- If available, following values will be updated from data of CSK_PersistentData module (check CSK_PersistentData module for this)
dnnClassification_Model.parametersName = 'CSK_DNNClassification_Parameter' -- name of parameter dataset to be used for this module
dnnClassification_Model.parameterLoadOnReboot = false -- Status if parameter dataset should be loaded on app/device reboot

--**************************************************************************
--********************** End Global Scope **********************************
--**************************************************************************
--**********************Start Function Scope *******************************
--**************************************************************************

-- Function to be up to date what instance is currently selected within the CSK_MultiDeepLearning module
---@param instanceNo int Number of instance
local function setDeepLearningInstance(instanceNo)
  dnnClassification_Model.selectedDLInstance = instanceNo
end
dnnClassification_Model.setDeepLearningInstance = setDeepLearningInstance

--*************************************************************************
--********************** End Function Scope *******************************
--*************************************************************************

return dnnClassification_Model
