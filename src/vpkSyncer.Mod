MODULE vpkSyncer;
IMPORT Strings, Out,
       strUtils, List,
       vpkSettings, vpkEnv, vpkConf, vpkGit, vpkdepTree, vpkTools, vpkHttps;

PROCEDURE mkTreePath(VAR path: ARRAY OF CHAR);
BEGIN
  vpkEnv.getConfDir(path);
  Strings.Append('/', path);
  Strings.Append(vpkSettings.vpkTreeDir, path);
END mkTreePath;

PROCEDURE sync*;
VAR
  tree: vpkSettings.tree;
BEGIN
  (* Syncing *)
  vpkConf.getConfigTreeVal(tree);
    IF tree.typ = vpkSettings.git THEN
      vpkGit.syncTree(tree.url, tree.branch)
    ELSE
      Out.String("TODO: not a git url"); Out.Ln
    END;
END sync;

PROCEDURE fetch*(VAR dep: vpkdepTree.Tdep; dst: ARRAY OF CHAR);
VAR domain: ARRAY 64 OF CHAR;
BEGIN
  Out.String("Starting fetch process..."); Out.Ln;
  Out.String("Destination: "); Out.String(dst); Out.Ln;
  IF dep = NIL THEN
    Out.String("Dependency is NIL"); Out.Ln;
    HALT(1);
  END;
  IF dep^.rmt = NIL THEN
    Out.String("Dependency remote is NIL"); Out.Ln;
    HALT(5);
  ELSE
    IF dep^.rmt IS vpkdepTree.RemoteGit THEN
      Out.String("Remote type is Git"); Out.Ln;
      vpkTools.extractDomainFromUrl(dep^.rmt^.URI, domain);
      Out.String("Extracted domain: "); Out.String(domain); Out.Ln;
      (* dst is changed by mkdefPkgDirPath and mkPkgdirPath *)
      IF dst = "" THEN
        vpkEnv.mkdefPkgDirPath(domain, dep^.name^, dst);
      ELSE
        vpkEnv.mkPkgDirPath(domain, dep^.name^, dst);
      END;
      Out.String("Final destination path: "); Out.String(dst); Out.Ln;
      Out.String("Fetching repository..."); Out.Ln;
      vpkGit.fetchRepo(dep^.rmt^.URI, dst, dep^.rmt(vpkdepTree.RemoteGit).branch);
    ELSIF dep^.rmt IS vpkdepTree.RemoteHttps THEN
      Out.String("Remote type is HTTPS"); Out.Ln;
      (* full dst will be determined in vpkHttps.fetchFiles for each file *)
      vpkHttps.fetchFiles(dep, dst);
    ELSE
      Out.String("TODO: neither git nor https url"); Out.Ln;
      Out.String("not handled");
      Out.Ln;
    END;
  END;
  Out.String("Fetch process completed."); Out.Ln;
END fetch;

END vpkSyncer.
