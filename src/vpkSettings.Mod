MODULE vpkSettings;
IMPORT Platform, Out;
CONST
  vpkConfDir*   = ".vipack";
  vpkConfFile*  = "vipackConf.json";
  vpkTreeDir*   = "vipackTree";
  treeURL*      = "https://github.com/vishaps/vipackTree";
  confTypGit*       = "git";
  confType*         = "type";
  confTermPath*     = "path";
  packageFileName* = "VersionFile.json";
  host* = "localhost";
  port* = "80";
  installPath* = "dependencies";

PROCEDURE getHome*(VAR path: ARRAY OF CHAR);
BEGIN
  IF ~(Platform.getEnv("HOME", path)) THEN
    Out.String("HOME variable is not found"); Out.Ln;
    HALT(1);
  END;
END getHome;

END vpkSettings.
