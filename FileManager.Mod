MODULE FileManager;
IMPORT Files, Out, Logger;

PROCEDURE Read*(fileName: ARRAY OF CHAR; VAR returnString: ARRAY OF CHAR): BOOLEAN;
VAR
    f: Files.File;
    r: Files.Rider;
    i: LONGINT; 
BEGIN
    f := Files.Old(fileName);
    
    IF f = NIL THEN 
        Logger.Log("-------------------");
        Logger.Log("File Name");
        Logger.Log(fileName);
        Logger.Log("File not found");
        Logger.Log("-------------------");
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

PROCEDURE Write*();
BEGIN

END Write;

END FileManager.