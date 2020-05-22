Set WshShell = WScript.CreateObject("WScript.Shell")

Dim exeName
'Dim statusCode

exeName = """C:\Program Files (x86)\Teams Installer\Teams.exe"""

statusCode = WshShell.Run (exeName, 1, true)

'MsgBox("End of Program")