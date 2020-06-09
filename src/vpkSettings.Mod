MODULE vpkSettings;
IMPORT Platform, Out;
CONST
  vpkConfDir*   = ".vipack";
  vpkConfFile*  = "vipackConf.json";
  vpkTreeDir*   = "vipackTree";

  graphName*      = "deps.dot";

  confTypKey*     = "type";
  confTypGitVal*  = "git";
  confTypHttpVal* = "http";
  confTreeKey*    = "path";
  defTreeVal*     = "https://github.com/vishaps/vipackTree";
  confTreeVal*    = defTreeVal;
  defTypVal*      = confTypGitVal;

  pkgTypKey*  = "Package";
  depTypKey*  = "Dependencies";

  packageFileName* = "VersionFile.json";
  host* = "localhost";
  port* = "80";
  installPath* = "dependencies";

  http* = 0;
   git* = 1;
  unkn* = -1;
TYPE
  tree* = RECORD
   url* : ARRAY 128 OF CHAR;
   typ* : SHORTINT
   END;



END vpkSettings.
