Set dtmConvertedDate = CreateObject("WbemScripting.SWbemDateTime")
Set WshShell = WScript.CreateObject("WScript.Shell")

strComputer = "."
Set objWMIService = GetObject("winmgmts:" _
    & "{impersonationLevel=impersonate}!\\" & strComputer & "\root\cimv2")

Set colOperatingSystems = objWMIService.ExecQuery _
    ("Select * from Win32_OperatingSystem")

For Each objOperatingSystem in colOperatingSystems

    BuildDate = mid(objOperatingSystem.InstallDate,1,8)
    'WScript.Echo BuildDate
    WshShell.RegWrite "HKLM\Software\Microsoft\Windows\CurrentVersion\Uninstall\Capgemini Image\InstallDate", BuildDate, "REG_SZ"
    
Next