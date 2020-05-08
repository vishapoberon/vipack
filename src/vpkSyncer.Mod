MODULE vpkSyncer;
IMPORT Strings, Out,
       vpkSettings, vpkEnv, vpkConf, vpkFiles, vpkGit;

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

END vpkSyncer.
