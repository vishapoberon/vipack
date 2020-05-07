MODULE vpkFileManager;
IMPORT Files, Out, vpkLogger, Strings, Platform;

PROCEDURE WriteString(VAR r : Files.Rider; str : ARRAY OF CHAR);
BEGIN
   Files.WriteBytes(r, str, Strings.Length(str));
END WriteString;

PROCEDURE Read*(fileName: ARRAY OF CHAR; VAR returnString: ARRAY OF CHAR): BOOLEAN;
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
END Read;

PROCEDURE Write*(fileName, content: ARRAY OF CHAR): BOOLEAN;
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
END Write;

PROCEDURE CreateDirectory*(name, path: ARRAY OF CHAR): BOOLEAN;
VAR
    command, path0: ARRAY 100 OF CHAR;
    errorCode: LONGINT;
BEGIN
    COPY(path, path0);
    COPY("mkdir -p ", command);
    Strings.Append("/", path0);
    Strings.Append(name, path0);
    Strings.Append(path0, command);
    errorCode := Platform.System(command);
    
    IF errorCode = 0 THEN RETURN TRUE
    ELSE RETURN FALSE END;
END CreateDirectory;

END vpkFileManager.
