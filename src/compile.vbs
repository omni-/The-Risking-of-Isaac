Set rex = New RegExp
rex.IgnoreCase = True
rex.Global = True
rex.Pattern = "((?:require(?:\(|\ )(?:\""|\'))(.+)(?:\""|\')(?:\))?)"

Set fso = CreateObject("Scripting.FileSystemObject")
basedir = fso.GetParentFolderName(fso.GetAbsolutePathName(WScript.Arguments(0))) & "\"

Sub parsefile(path, outfile)
    Set inFile = fso.GetFile(path)
    Set inStream = inFile.OpenAsTextStream(1, -2)
    
    Do Until inStream.AtEndOfStream
        strLine = inStream.ReadLine
        
        Set matches = rex.Execute(strLine)
        If (matches.Count > 0)  Then
            Set match = matches(0)
            splitArr = Split(strLine, match.SubMatches(0))
            outfile.WriteLine(splitArr(0) & "(function()" & vbCrLf)
            
            requFilePath = basedir & Replace(match.SubMatches(1), ".", "\") & ".lua"
            parsefile requFilePath, outfile
 
            outfile.WriteLine(vbCrLf & "end)() " & splitArr(1))
        Else 
           outFile.WriteLine(strLine)
        End If
    Loop
    inStream.Close
End Sub


Set outFile = fso.CreateTextFile(WScript.Arguments(1), True)
parsefile WScript.Arguments(0), outFile 
outFile.Close