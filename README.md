# CSK_Application_DNNClassification

CSK application to make use of MachineLearning DeepNeuralNetwork algorithm to process images and obtain the result as a classification derived from the used neural network.  
This application combines functions of different CSK modules to realize this functionality.  

![](https://github.com/SICKAppSpaceCodingStarterKit/CSK_Application_DNNClassification/blob/main/docu/media/UI_Screenshot.png)

## How to Run

The application includes an intuitive GUI to setup a system to load a DeepNeuralNetwork and to process images to get a decision to what class of the DNN it belongs.  
The application is intended for devices like SIM4000, SIM2x00 family, SIM1012, SIM1004 and SAE with pico-/midiCam 1st or 2nd generation or other GigE Vision cameras.  
It can run with multiple instances in parallel.  
For further information regarding the internal used functions / events check out the [documentation](https://raw.githack.com/SICKAppSpaceCodingStarterKit/CSK_Application_DnnClassification/main/docu/CSK_Application_DNNClassification.html) in the folder "docu".

## Information

Tested on  

1. SIM1012        - Firmware 2.2.0  
2. SIM2500        - Firmware 1.3.0  
3. SICK AppEngine - Firmware 1.3.2  

**IMPORTANT**  
Following CSK modules are used for this application via Git subtrees and should NOT be further developed within this repository (see [contribution guideline](https://github.com/SICKAppSpaceCodingStarterKit/.github/blob/main/Contribution_Guideline.md) of this GitHub organization):  

  * CSK_1stModule_Logger           (release 4.0.0)
  * CSK_Module_DateTime            (release 3.0.0)
  * CSK_Module_DeviceScanner       (release 2.0.0)
  * CSK_Module_FTPClient           (release 3.0.0)
  * CSK_Module_ImagePlayer         (release 2.4.0)
  * CSK_Module_MultiDeepLearning   (release 4.0.0)
  * CSK_Module_MultiRemoteCamera   (release 5.0.0)
  * CSK_Module_PersistentData      (release 4.0.0)
  * CSK_Module_PowerManager        (release 2.5.0)

This application is part of the SICK AppSpace Coding Starter Kit developing approach.  
It is programmed in an object oriented way. Some of the modules use kind of "classes" in Lua to make it possible to reuse code / classes in other projects.  
In general it is not neccessary to code this way, but the architecture of this app can serve as a sample to be used especially for bigger projects and to make it easier to share code.  
Please check the [documentation](https://github.com/SICKAppSpaceCodingStarterKit/.github/blob/main/docu/SICKAppSpaceCodingStarterKit_Documentation.md) of CSK for further information.  

## Topics

Coding Starter Kit, Multi, Camera, SIM, Image-2D, Module, SICK-AppSpace, DNN, MachineLearning, DeepLearning
