MODULE vpkHttps;
IMPORT Out,
       List, https,
       vpkdepTree;

PROCEDURE fetchFiles*(VAR dep: vpkdepTree.Tdep; dst: ARRAY OF CHAR);
VAR
  i: LONGINT;
  node: List.Node;
BEGIN
  Out.String("fetching ");
  Out.Int(dep^.rmt(vpkdepTree.RemoteHttps)^.Files.Count, 0); Out.String(" files"); Out.Ln;
  i := 0;

  REPEAT
    node := dep^.rmt(vpkdepTree.RemoteHttps)^.Files.Get(dep^.rmt(vpkdepTree.RemoteHttps)^.Files, i);
    Out.String("file: "); Out.String(node^.obj(vpkdepTree.File)^.URI); Out.Ln;

    INC(i)
  UNTIL i = dep^.rmt(vpkdepTree.RemoteHttps)^.Files.Count;

END fetchFiles;

END vpkHttps.
