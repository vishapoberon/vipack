MODULE vpkGit;
IMPORT Out,Strings, Platform;

PROCEDURE clone*(URL : ARRAY OF CHAR);
VAR i : INTEGER;
cmd : ARRAY 120 OF CHAR;
BEGIN
i:=Platform.System("git init .");
cmd := "git clone ";
Strings.Append(URL, cmd);
i := Platform.System(cmd);
Out.Int(i,0);
END clone;


BEGIN

END vpkGit.
