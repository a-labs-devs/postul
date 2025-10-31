Set WshShell = CreateObject("WScript.Shell")
Set objArgs = WScript.Arguments

If objArgs.Count > 0 Then
    ' Obter o diretório do script
    scriptPath = objArgs(0)
    arg = ""
    If objArgs.Count > 1 Then
        arg = " " & objArgs(1)
    End If
    
    ' Executar o bat em uma nova janela visível, repassando argumentos se houver
    WshShell.Run "cmd /c """ & scriptPath & "\start-server-window.bat" & arg & """", 1, False
End If
