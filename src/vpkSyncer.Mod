MODULE vpkSyncer;
IMPORT Strings, Out,
       vpkSettings, vpkConf, vpkFsHelper, vpkFileManager, vpkJsonParser, vpkGit;

PROCEDURE mkTreePath(VAR path: ARRAY OF CHAR);
BEGIN
  vpkConf.getConfDir(path);
  Strings.Append('/', path);
  Strings.Append(vpkSettings.vpkTreeDir, path);
END mkTreePath;

PROCEDURE sync*;
VAR
  dir : vpkFsHelper.fileInfo;
  jsonData: ARRAY 256 OF CHAR;
  jsonURL: ARRAY 64 OF CHAR;
  jsonType: ARRAY 8 OF CHAR;
  b: BOOLEAN;
  confPath, treePath : ARRAY 256 OF CHAR;
  jsonRecord : vpkJsonParser.JsonTypePointer;
BEGIN
  mkTreePath(treePath);
  Out.String("*****************************************"); Out.Ln;
  Out.String("TreePath = "); Out.String(treePath); Out.Ln;
  (* Check tree directory if doesn't exist create*)
  dir.name := treePath;
  IF ~vpkFsHelper.Exists(dir) THEN
    Out.String(treePath); Out.String(" directory doesn't exist, creating"); Out.Ln;
    b := vpkFsHelper.mkDir(treePath);
  ELSE
    IF ~(vpkFsHelper.dir IN dir.attr) THEN
      Out.String(treePath); Out.String(" exists but is not a directory"); Out.Ln;
      HALT(1);
    END;
    (* Syncing *)
    vpkConf.getConfPath(confPath);
    b := vpkFileManager.Read(confPath, jsonData);
    jsonRecord := vpkJsonParser.Create(jsonData);
    b := vpkJsonParser.GetTerminal(jsonRecord, vpkSettings.confTermPath, jsonURL);
    Out.String("URL = "); Out.String(jsonURL); Out.Ln;
    b := vpkJsonParser.GetTerminal(jsonRecord, vpkSettings.confType, jsonType);
    IF jsonType = vpkSettings.confTypGit THEN
      vpkGit.pull(jsonURL, treePath)
    ELSE
      Out.String("not a git url"); Out.Ln
    END;
  END;
END sync;

END vpkSyncer.
