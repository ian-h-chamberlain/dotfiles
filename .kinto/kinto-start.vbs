Set oShell = CreateObject("Shell.Application")
Set wShell = WScript.CreateObject("WScript.Shell")
Set fso = CreateObject("Scripting.FileSystemObject")

path = wShell.ExpandEnvironmentStrings("""%userprofile%")
strFolder = fso.BuildPath( path, "\.kinto\kinto.ahk"" win")
oShell.ShellExecute "C:\Program Files\AutoHotkey\AutoHotkey.exe", strFolder, , , 0
