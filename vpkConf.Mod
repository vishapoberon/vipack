MODULE vpkConf;
IMPORT Files;

PROCEDURE confExists*(VAR confFile: ARRAY OF CHAR ):BOOLEAN;
BEGIN
	IF  Files.Old(confFile) = NIL THEN RETURN FALSE;
	ELSE RETURN TRUE;
	END;

END confExists;

PROCEDURE makeConf*(VAR confFilePath: ARRAY OF CHAR);
VAR f : Files.File;
BEGIN

f := Files.New(confFilePath);
Files.Register(f);

END makeConf;


BEGIN


END vpkConf.
