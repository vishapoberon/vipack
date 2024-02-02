MODULE vpkSyncer;
IMPORT Strings, Out,
       strUtils,
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
      vpkGit.syncTree(tree.url, tree.branch)
    ELSE
      Out.String("TODO: not a git url"); Out.Ln
    END;
END sync;

PROCEDURE fetch*(name, url, dmn, typ, dst, branch: ARRAY OF CHAR);
BEGIN
  IF dst = "" THEN
    vpkEnv.mkdefPkgDirPath(dmn, name, dst);
  ELSE
    vpkEnv.mkPkgDirPath(dmn, name, dst);
  END;
  (* dst is changed by mkdefPkgDirPath and mkPkgdirPath *)
  IF typ = vpkSettings.rmtTypGitVal THEN
    vpkGit.fetchRepo(url, dst, branch);
  ELSE
    Out.String("TODO: not a git url"); Out.Ln
  END
END fetch;

END vpkSyncer.
