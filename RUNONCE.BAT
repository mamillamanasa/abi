#**********************************************************************
#*								                 	
#* Program Name		: Runonce.bat				                        
#* Author		: Rob Sherer                                                    
#* Copyright		: Capgemini/Sogeti                                     
#*								                 	
#* Creation date	: 2010/07/16 Rob Sherer  			                
#* Last update		: 2016/02/16 Arun Kumar Kannan      
#* 			: 2017/07/24 Ritesh Kumar
#*                      : 2018/09/13 Daud Khan Afridi	                 
#* Version		: 1.7	   	
#*								                 	
#* Operating System	: Windows 10  	1803		                 	
#* Type			: Batch Script        			                 
#* Usage		: 		     			         
#*				                      		          	 	 
#* Description		: First script to execute in images. Initializes other scripts to execute.Add ConfigUser to User Runonce || Add RunHTA to Machine Run 
#*                        || Initiate OS_InstallDate.vbs || Copy Global anyconnect Profile || Enable SBL for anyconnect || Hide SCCM client cache folder 
#*                        || Set Network binding Order || Turn-off Customer Experience Improvement Program || Disbale Troom users creds popup 
#*                        || Disable Adobe auto update || Disable Adobe Reader Improvement Program || Disable Updates options for MS Silverlight 5 
#*                        || Add Image OEMInformation || Disable GIMS tour || Add GPPT Tools in Start Menu || Block deployment of IE10 
#*                        || Turn-off Windows Error Reporting || Disable Cisco AnyConnect Startup || Disable anyconect Credential Caching
#*
#* Version 1.0		: Initial Version
#* Version 1.1		: Removed GPPT tools copy step
#* Version 1.2		: Added Logging
#* Version 1.4          : Removed Adobe,Silverlight update,IE update block and Anyconnect settings sections as we are handling them in respective packages now.	
#* Version 1.5          : Added Remote registry commands					          	 	
#* Version 1.6          : Removed Remote registry commands
#* Version 1.7          : Added LAnguage  Bar hide
#**********************************************************************

Echo Creating Log directories
mkdir C:\SCCM_logs
rmdir C:\Inetpub /Q /S

@echo off
Echo ------------------------------------------------------------------------------>> C:\SCCM_logs\Runonce.Log 2>&1
Echo 					***Script Execution Starts*** >> C:\SCCM_logs\Runonce.Log 2>&1
Echo ------------------------------------------------------------------------------ >> C:\SCCM_logs\Runonce.Log 2>&1



Echo Setting Environment Variables
Start cmd /c SetX -m "GPPT_LOGFOLDER" "C:\SCCM_logs"
Start cmd /c SetX -m "GPPT_INSTALLFOLDER" "c:\Installers"
Start cmd /c SetX -m "GPPT_CACHEFOLDER" "C:\Windows\ccmcache"

@echo off

Echo ################################################################################################################## >> C:\SCCM_logs\Runonce.Log 2>&1

Echo Configure Default User settings >> C:\SCCM_logs\Runonce.Log 2>&1

reg load HKU\DEF %SystemDrive%\Users\Default\NTUSER.DAT >> C:\SCCM_logs\Runonce.Log 2>&1
reg add HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Run /v ConfigUser /t REG_SZ /d "C:\Program Files\GPPTScripts\UserConfig.vbs" /F >> C:\SCCM_logs\Runonce.Log 2>&1
rem reg add "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Active Setup\Installed Components\RunUserConfig" /v "StubPath" /t REG_SZ /d "C:\Program Files\GPPTScripts\UserConfig.vbs" /F >> C:\SCCM_logs\Runonce.Log 2>&1
reg add HKEY_USERS\DEF\Software\Microsoft\CTF\LangBar /v ShowStatus /t REG_DWORD /d "3" /F >> C:\SCCM_logs\Runonce.Log 2>&1
reg query HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Run /v ConfigUser >> C:\SCCM_logs\Runonce.Log 2>&1
reg add HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Run /v RunWizard /t REG_SZ /d "%SystemDrive%\Program Files\GPPTScripts\GPPTwizard.exe" /F >> C:\SCCM_logs\Runonce.Log 2>&1
reg query HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Run /v RunWizard >> C:\SCCM_logs\Runonce.Log 2>&1
rem reg import "%SystemDrive%\program Files\GPPTScripts\UserConfig.reg" >> C:\SCCM_logs\Runonce.Log 2>&1
reg unload HKU\DEF >> C:\SCCM_logs\Runonce.Log 2>&1

Echo ################################################################################################################## >> C:\SCCM_logs\Runonce.Log 2>&1

Echo Importing FVE configurations to help bitlocker actions >> C:\SCCM_logs\Runonce.Log 2>&1
reg import "%SystemDrive%\program Files\GPPTScripts\FVE.reg" >> C:\SCCM_logs\Runonce.Log 2>&1

Echo ################################################################################################################## >> C:\SCCM_logs\Runonce.Log 2>&1

Echo Turn-off Customer Experience Improvement Program (CEIPEnable=0) >> C:\SCCM_logs\Runonce.Log 2>&1
reg add "HKLM\SOFTWARE\Microsoft\SQMClient\Windows" /v "CEIPEnable" /t REG_DWORD /d 0 /f >> C:\SCCM_logs\Runonce.Log 2>&1
reg query "HKLM\SOFTWARE\Microsoft\SQMClient\Windows" /v "CEIPEnable" >> C:\SCCM_logs\Runonce.Log 2>&1

Echo ################################################################################################################## >> C:\SCCM_logs\Runonce.Log 2>&1

Echo Avoid pop-up asking for user credential when downloading a file from troom (AuthForwardServerList=*.capgemini.com) >> C:\SCCM_logs\Runonce.Log 2>&1
reg add "HKLM\SYSTEM\CurrentControlSet\Services\WebClient\Parameters" /v "AuthForwardServerList" /t REG_MULTI_SZ /d *.capgemini.com /f >> C:\SCCM_logs\Runonce.Log 2>&1
reg query "HKLM\SYSTEM\CurrentControlSet\Services\WebClient\Parameters" /v "AuthForwardServerList" >> C:\SCCM_logs\Runonce.Log 2>&1

Echo ################################################################################################################## >> C:\SCCM_logs\Runonce.Log 2>&1

Echo Image info in Add-Remove >> C:\SCCM_logs\Runonce.Log 2>&1
FOR /F "skip=2 tokens=2,*" %%A IN ('reg query "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\OEMInformation" /v "Model"') DO set "Ver=%%B"
reg add "HKEY_LOCAL_MACHINE\Software\Microsoft\Windows\CurrentVersion\Uninstall\Capgemini Image" /v "DisplayVersion" /t REG_SZ /d "%Ver%" /F >> C:\SCCM_logs\Runonce.Log 2>&1
reg add "HKEY_LOCAL_MACHINE\SOFTWARE\Wow6432Node\SCCMOSDTatoo" /v "CGImageVersion" /t REG_SZ /d "%Ver%" /F  >> C:\SCCM_logs\Runonce.Log 2>&1
reg add "HKLM\Software\Microsoft\Windows\CurrentVersion\Uninstall\Capgemini Image" /v "DisplayName" /t REG_SZ /d "GPPT Windows 10 Professional" /f  
Cscript "C:\Program Files\GPPTScripts\OS_InstallDate.vbs" >> C:\SCCM_logs\Runonce.Log 2>&1
reg query "HKEY_LOCAL_MACHINE\Software\Microsoft\Windows\CurrentVersion\Uninstall\Capgemini Image" >> C:\SCCM_logs\Runonce.Log 2>&1

Echo ################################################################################################################## >> C:\SCCM_logs\Runonce.Log 2>&1

Echo Image OEMInformation >> C:\SCCM_logs\Runonce.Log 2>&1
reg add "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\OEMInformation" /v "Manufacturer" /t REG_SZ /d "Capgemini/Sogeti" /F
reg add "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\OEMInformation" /v "SupportURL" /t REG_SZ /d "https://talent.capgemini.com/global/pages/hubs/global_functions/group_it/tools/infrastructure/it_help/contact_us/" /F
reg query "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\OEMInformation" >> C:\SCCM_logs\Runonce.Log 2>&1

Echo ################################################################################################################## >> C:\SCCM_logs\Runonce.Log 2>&1

Echo Turn-off Windows Error Reporting (Disabled=1) >> C:\SCCM_logs\Runonce.Log 2>&1
reg add "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\Windows Error Reporting" /v "Disabled" /t REG_DWORD /d 1 /f >> C:\SCCM_logs\Runonce.Log 2>&1
reg query "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\Windows Error Reporting" /v "Disabled" >> C:\SCCM_logs\Runonce.Log 2>&1

Echo ################################################################################################################## >> C:\SCCM_logs\Runonce.Log 2>&1
Echo Disable Cisco Anyconnect autostart >> C:\SCCM_logs\Runonce.Log 2>&1
Reg Delete "HKEY_LOCAL_MACHINE\SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Run" /v "Cisco AnyConnect Secure Mobility Agent for Windows" /f>> C:\SCCM_logs\Runonce.Log 2>&1

Echo ################################################################################################################## >> C:\SCCM_logs\Runonce.Log 2>&1

Echo creating IE shortcut >> C:\SCCM_logs\Runonce.Log 2>&1
Xcopy "c:\Program Files\GPPTScripts\Internet Explorer.lnk" "%ALLUSERSPROFILE%\Microsoft\Windows\Start Menu\Programs\Accessories\" /h /e /q /y >> C:\SCCM_logs\Runonce.Log 2>&1

Echo ################################################################################################################## >> C:\SCCM_logs\Runonce.Log 2>&1
Echo Disable Fast User Switching >> C:\SCCM_logs\Runonce.Log 2>&1
Reg Add "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" /v HideFastUserSwitching /t REG_DWORD /d 1 /F >> C:\SCCM_logs\Runonce.Log 2>&1

Echo ################################################################################################################## >> C:\SCCM_logs\Runonce.Log 2>&1
Echo Disable Windows Update >> C:\SCCM_logs\Runonce.Log 2>&1
Reg Add "HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU" /v NoAutoUpdate /t REG_DWORD /d 1 /F >> C:\SCCM_logs\Runonce.Log 2>&1

Echo ################################################################################################################## >> C:\SCCM_logs\Runonce.Log 2>&1
Echo Disable IE Customization at First Run >> C:\SCCM_logs\Runonce.Log 2>&1
Reg Add "HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Internet Explorer\Main" /v DisableFirstRunCustomize /t REG_DWORD /d 1 /F >> C:\SCCM_logs\Runonce.Log 2>&1
powershell.exe -windowstyle hidden -executionpolicy unrestricted -file "%SystemDrive%\Program Files\GPPTScripts\WirelessPreferredBand.ps1"
Echo ################################################################################################################## >> C:\SCCM_logs\Runonce.Log 2>&1
Echo Remove CCTK shortcuts >> C:\SCCM_logs\Runonce.Log 2>&1
Rmdir "C:\programdata\Microsoft\Windows\Start Menu\Programs\Dell System Manager" /Q /S
RmDir "C:\programdata\Microsoft\Windows\Start Menu\Programs\Dell" /Q /S
Del "C:\Users\Public\Desktop\Dell CCTK Configuration Wizard.lnk" /Q /S
Dism.exe /Online /Import-DefaultAppAssociations:"C:\Program Files\GPPTScripts\FileDefaultAssociations.xml"
Echo ------------------------------------------------------------------------------>> C:\SCCM_logs\Runonce.Log 2>&1
Echo 					***Script Execution Completed*** >> C:\SCCM_logs\Runonce.Log 2>&1
Echo ------------------------------------------------------------------------------ >> C:\SCCM_logs\Runonce.Log 2>&1

