MODULE vpkStorage;
IMPORT Files, Out, Strings,
strUtils, vpkLogger, vpkEnv, vpkFiles;

PROCEDURE WriteString(VAR r : Files.Rider; str : ARRAY OF CHAR);
BEGIN
   Files.WriteBytes(r, str, Strings.Length(str));
END WriteString;

PROCEDURE fileToString*(VAR fileName: ARRAY OF CHAR; VAR returnString: strUtils.pstring);
VAR
    f: Files.File;
    r: Files.Rider;
    i, j: LONGINT; 
BEGIN
    returnString := NIL;
    f := Files.Old(fileName);
    IF f # NIL THEN 
      Files.Set(r, f, 0);
      i := Files.Length(f); 
      NEW(returnString, i);
      j := 0;
      REPEAT
        Files.Read(r, returnString^[j]);
        INC(j);
      UNTIL r.eof OR (j >= i);
    ELSE
      Out.String("file ");
      Out.String(fileName);
      Out.String(" not found");
      Out.Ln;
    END;

END fileToString;

PROCEDURE stringToFile*(VAR fileName, content: ARRAY OF CHAR): BOOLEAN;
VAR
    f: Files.File;
    r: Files.Rider;
    i: LONGINT;
BEGIN
    f := Files.New(fileName);

    IF f = NIL THEN 
        vpkLogger.Log(fileName);
        vpkLogger.Log(" not found");
        vpkLogger.Ln;
        RETURN FALSE
    END;

    Files.Set(r, f, 0);
    vpkLogger.Log("Writing to file");
    vpkLogger.Log(fileName);
    vpkLogger.Log("-------------------");
    WriteString(r, content);

    Files.Register(f);
    Files.Close(f);
    RETURN TRUE;
END stringToFile;

PROCEDURE json2pstring*(VAR json: ARRAY OF CHAR; VAR pstr: strUtils.pstring);
VAR
  fi: vpkFiles.fileInfo;
BEGIN
  pstr := NIL;
  vpkEnv.getTreeDir(fi.name);
  Strings.Append("/", fi.name);
  Strings.Append(json, fi.name);
  Strings.Append(".json", fi.name); 
  IF vpkFiles.Exists(fi) THEN
    fileToString(fi.name, pstr);
  END
END json2pstring;

END vpkStorage.
