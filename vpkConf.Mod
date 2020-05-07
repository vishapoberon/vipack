MODULE vpkConf;
IMPORT Out, Files, Strings, Platform,
       vpkFsHelper;

PROCEDURE confExists*(VAR confFile: ARRAY OF CHAR ):BOOLEAN;
BEGIN
	IF  Files.Old(confFile) = NIL THEN RETURN FALSE;
	ELSE RETURN TRUE;
	END;

END confExists;

PROCEDURE makeFile*(VAR confFilePath: ARRAY OF CHAR);
VAR f : Files.File;
BEGIN
f := Files.New(confFilePath);
Files.Register(f);

END makeFile;

PROCEDURE makeDir*(VAR confDirPath: ARRAY OF CHAR):BOOLEAN;
BEGIN
RETURN vpkFsHelper.mkDir(confDirPath);
END makeDir;

PROCEDURE varCheck*(variable : ARRAY OF CHAR;VAR  value : ARRAY OF CHAR): BOOLEAN;
BEGIN
RETURN Platform.getEnv(variable,value);
END varCheck;

PROCEDURE writeInFile*(VAR pathToFile : ARRAY OF CHAR;VAR text : ARRAY OF CHAR; posRider : INTEGER);
VAR f : Files.File;
	r : Files.Rider;
BEGIN
f := Files.Old(pathToFile);
Files.Set(r,f,posRider);
Files.WriteBytes(r, text, Strings.Length(text));
Files.Close(f);
END writeInFile;


BEGIN


END vpkConf.
