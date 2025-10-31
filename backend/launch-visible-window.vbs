Set WshShell = CreateObject("WScript.Shell")
Set objArgs = WScript.Arguments

If objArgs.Count > 0 Then
    ' Obter o diretório do script
    scriptPath = objArgs(0)
    
    ' Executar o bat em uma nova janela visível
    WshShell.Run "cmd /k """ & scriptPath & "\start-server-window.bat""", 1, False
End If
