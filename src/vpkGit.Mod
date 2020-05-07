MODULE vpkGit;
IMPORT Out, Strings, Platform;

PROCEDURE pull*(URL : ARRAY OF CHAR; dst : ARRAY OF CHAR);
VAR i : INTEGER;
    cmd : ARRAY 120 OF CHAR;
BEGIN
  cmd:= "git init ";
  Strings.Append(dst, cmd);
  i:=Platform.System(cmd);
  cmd := "";
  cmd := "git -C ";
  Strings.Append(dst,cmd);
  Strings.Append(" pull ",cmd);
  Strings.Append(URL, cmd);
  i := Platform.System(cmd);
  Out.Int(i,0);
END pull;


BEGIN

END vpkGit.
