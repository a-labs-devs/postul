Set WshShell = CreateObject("WScript.Shell")
Set objArgs = WScript.Arguments

If objArgs.Count > 0 Then
    scriptPath = objArgs(0)
    WshShell.Run "powershell.exe -NoExit -ExecutionPolicy Bypass -File """ & scriptPath & """", 1, False
End If
