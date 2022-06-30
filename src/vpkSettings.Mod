MODULE vpkSettings;
IMPORT Platform, Out;
CONST
  vpkConfDir*   = ".vipack";
  vpkConfFile*  = "vipackConf.json";
  vpkTreeDir*   = "vipackTree";
  vpkPkgDir*    = "vpkLocal";
  vpkDepDir*    = "deps";
  vpkBldDir*    = "build";

  graphName*      = "deps.dot";

  rmtType*           = "Remote";
  rmtTypKey*         = "type";
  rmtTypGitVal*      = "git";
  rmtTypHttpVal*     = "http";
  rmtTypHttpsVal*    = "https";
  rmtTypGemiVal*     = "gemini";
  rmtTreeKey*        = "path";
  rmtTreeBranchKey*  = "branch";
  bldType*           = "Build";
  (*defTreeVal*      = "https://github.com/vishaps/vipackTree";*)
  defTreeVal*        = "git@github.com:vishaps/vipackTree";
  confTreeVal*       = defTreeVal;
  defTypVal*         = rmtTypGitVal;

  pkgTypKey*  = "Package";
  depTypKey*  = "Dependencies";

  packageFileName* = "VersionFile.json";
  host* = "localhost";
  port* = "80";

  http*   = 0;
  https*  = 1;
  gemini* = 2;
     git* = 3;
  unkn* = -1;
TYPE
  tree* = RECORD
   url* : ARRAY 128 OF CHAR;
   typ* : SHORTINT;
 branch*: ARRAY 128 OF CHAR;
   END;



END vpkSettings.
