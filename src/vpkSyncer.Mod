MODULE vpkSyncer;
IMPORT Strings, Out,
       vpkSettings, vpkEnv, vpkConf, vpkGit;

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
      vpkGit.syncTree(tree.url)
    ELSE
      Out.String("TODO: not a git url"); Out.Ln
    END;
END sync;

PROCEDURE fetch*(name, url, typ, dst: ARRAY OF CHAR);
BEGIN
  IF dst = "" THEN
    vpkEnv.mkdefPkgDirPath(name, dst);
  ELSE
    vpkEnv.mkPkgDirPath(name, dst);
  END;

  IF typ = vpkSettings.rmtTypGitVal THEN 
    vpkGit.fetchRepo(url, dst);
  ELSE
    Out.String("TODO: not a git url"); Out.Ln
  END
END fetch;

END vpkSyncer.
