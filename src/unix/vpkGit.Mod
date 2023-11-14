MODULE vpkGit;
IMPORT Out, Strings, Platform, vpkEnv;

PROCEDURE pull*(VAR url : ARRAY OF CHAR; VAR dst : ARRAY OF CHAR; VAR branch: ARRAY OF CHAR);
VAR i : INTEGER;
    cmd : ARRAY 2048 OF CHAR;
BEGIN
  cmd := "git init ";
  Strings.Append(dst, cmd);
  i:=Platform.System(cmd);
  (*cmd := "git -C ";
  Strings.Append(dst, cmd);
  Strings.Append(" remote add origin ", cmd);
  Strings.Append(url, cmd);
  i:=Platform.System(cmd);*)
  cmd := "";
  cmd := "git -C ";
  Strings.Append(dst, cmd);
  Strings.Append(" pull ", cmd);
  Strings.Append(url, cmd);
  Out.String("branch: '"); Out.String(branch); Out.String("'."); Out.Ln;
  IF branch # "" THEN
    Out.String("adding branch to commandline"); Out.Ln;
    Strings.Append(" ", cmd);
    Strings.Append(branch, cmd);
  END;
  Out.String("fetch command: '"); Out.String(cmd); Out.Char("'"); Out.Ln;
  i := Platform.System(cmd);
END pull;

PROCEDURE syncTree*(url, branch: ARRAY OF CHAR);
VAR
  tmp: ARRAY 256 OF CHAR;
BEGIN
  vpkEnv.getTreeDir(tmp);
  pull(url, tmp, branch);
END syncTree;

PROCEDURE fetchRepo*(url: ARRAY OF CHAR; dst, branch: ARRAY OF CHAR);
BEGIN
  pull(url, dst, branch);
END fetchRepo;

END vpkGit.
