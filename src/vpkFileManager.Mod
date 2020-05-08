MODULE vpkFileManager;
IMPORT Files, Out, Strings, Platform,
vpkLogger, vpkFiles;

PROCEDURE WriteString(VAR r : Files.Rider; str : ARRAY OF CHAR);
BEGIN
   Files.WriteBytes(r, str, Strings.Length(str));
END WriteString;

PROCEDURE fileToString*(fileName: ARRAY OF CHAR; VAR returnString: ARRAY OF CHAR): BOOLEAN;
VAR
    f: Files.File;
    r: Files.Rider;
    i: LONGINT; 
BEGIN
    f := Files.Old(fileName);
    
    IF f = NIL THEN 
        vpkLogger.Log("-------------------");
        vpkLogger.Log("File Name");
        vpkLogger.Log(fileName);
        vpkLogger.Log("File not found");
        vpkLogger.Log("-------------------");
        RETURN FALSE
    END;

    Files.Set(r, f, 0);
    
    i := 0;
    REPEAT
        Files.Read(r, returnString[i]);
        INC(i);
    UNTIL r.eof OR (i>=LEN(returnString));

    RETURN TRUE;
END fileToString;

PROCEDURE stringToFile*(fileName, content: ARRAY OF CHAR): BOOLEAN;
VAR
    f: Files.File;
    r: Files.Rider;
    i: LONGINT;
BEGIN
    f := Files.New(fileName);

    IF f = NIL THEN 
        vpkLogger.Log("-------------------");
        vpkLogger.Log("File Name");
        vpkLogger.Log(fileName);
        vpkLogger.Log("File not found");
        vpkLogger.Log("-------------------");
        RETURN FALSE
    END;

    Files.Set(r, f, 0);
    vpkLogger.Log("Writing to file");
    vpkLogger.Log(fileName);
    vpkLogger.Log("-------------------");
    WriteString(r, content);

    Files.Register(f);

    RETURN TRUE;
END stringToFile;

PROCEDURE createDir*(name, path: ARRAY OF CHAR): BOOLEAN;
VAR
    p : POINTER TO ARRAY OF CHAR;
BEGIN
    NEW(p, Strings.Length(name) + Strings.Length(path) + 1);
    COPY(path, p^);
    Strings.Append("/", p^);
    Strings.Append(name, p^);
    RETURN vpkFiles.mkDir(p^)
END createDir;

END vpkFileManager.
