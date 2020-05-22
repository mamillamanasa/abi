	'***Run GPPTWizard.exe as Administrator
	Set WshNetwork = WScript.CreateObject("WScript.Network")
	Cuser = WshNetwork.UserName
	On Error Resume Next
	Set objShell = CreateObject("Shell.Application") 
	path = "C:\Program Files\GPPTscripts"
	Set objFolder = objShell.Namespace (""& path)
	Set objApp = objFolder.ParseName("GPPTwizard.exe") 
	For Each verb in objApp.Verbs() 
		If verb.Name = "Run as &administrator" Then verb.DoIt 
	Next