MODULE vpkHttp;
IMPORT Out, Platform,
       List, strTypes, http,
       vpkdepTree, vpkTools, vpkMD5Checker, vpkEnv;

PROCEDURE fetchFiles*(VAR dep: vpkdepTree.Tdep; dst: ARRAY OF CHAR);
VAR
  h: http.Client;
  answer: strTypes.pstring;
  domain, path: ARRAY 128 OF CHAR; port: ARRAY 8 OF CHAR;
  filename: ARRAY 64 OF CHAR;
  i, j: LONGINT;
  node: List.Node;
  bool, continueFetching: BOOLEAN;
  initialDst: ARRAY 512 OF CHAR;
BEGIN
  COPY(dst, initialDst);
  COPY("80", port);
  i := 0;
  continueFetching := TRUE;

  WHILE continueFetching DO
    node := dep^.rmt(vpkdepTree.RemoteHttps)^.Files.Get(dep^.rmt(vpkdepTree.RemoteHttps)^.Files, i);
    IF node # NIL THEN
      IF node^.obj(vpkdepTree.File) # NIL THEN
        Out.String("getting "); Out.String(node^.obj(vpkdepTree.File)^.URI); Out.Ln;

        vpkTools.extractDomainFromUrl(node^.obj(vpkdepTree.File)^.URI, domain);
        Out.String("connecting to "); Out.String(domain); Out.Ln;
        vpkTools.extractPathFromUrl(node^.obj(vpkdepTree.File)^.URI, path);
        vpkTools.extractFilenameFromUrl(node^.obj(vpkdepTree.File)^.URI, filename);

        vpkEnv.mkPkgDirPath(domain, dep^.name^, dst);

        j := Platform.Chdir(dst);

        COPY(initialDst, dst);

        h := http.Create(domain, port, path);

        IF node^.obj(vpkdepTree.File)^.auth THEN
          Out.String("requires basic auth"); Out.Ln;
          Out.String("username: "); Out.String(node^.obj(vpkdepTree.File)^.username); Out.Ln;
          Out.String("password: "); Out.String(node^.obj(vpkdepTree.File)^.password); Out.Ln;

          h.appendAuthHdr(h, node^.obj(vpkdepTree.File)^.username, node^.obj(vpkdepTree.File)^.password);
        ELSE
          Out.String("does not require basic auth"); Out.Ln;
        END;

        (*h.Init(h);*)
        answer := h.Get(h);
        h.Save(h);
        bool := vpkMD5Checker.checkMD5(filename, node^.obj(vpkdepTree.File)^.md5);
        IF bool THEN Out.String("correct!") ELSE Out.String("incorrect!"); END; Out.Ln;
      ELSE
        Out.String("node^.obj(vpkdepTree.File) is NIL"); Out.Ln;
      END;
    ELSE
      Out.String("Node is NIL, stopping."); Out.Ln;
      continueFetching := FALSE;
    END;
    INC(i);
  END;

END fetchFiles;

END vpkHttp.
