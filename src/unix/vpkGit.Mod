MODULE vpkGit;
IMPORT Out, Strings, Platform, vpkEnv;

PROCEDURE pull*(url : ARRAY OF CHAR; dst : ARRAY OF CHAR);
VAR i : INTEGER;
    cmd : ARRAY 120 OF CHAR;
BEGIN
  cmd:= "git init ";
  Strings.Append(dst, cmd);
  i:=Platform.System(cmd);
  cmd := "";
  cmd := "git -C ";
  Strings.Append(dst, cmd);
  Strings.Append(" pull ", cmd);
  Strings.Append(url, cmd);
  i := Platform.System(cmd);
  Out.Int(i, 0);
END pull;

PROCEDURE syncTree*(url: ARRAY OF CHAR);
VAR
  tmp: ARRAY 256 OF CHAR;
BEGIN
  vpkEnv.getTreeDir(tmp);
  pull(url, tmp);
END syncTree;

END vpkGit.
