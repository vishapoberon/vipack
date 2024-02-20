MODULE vpkSettings;
IMPORT Platform, Out;
CONST
  (* remotes *)
  http*   = 0; httpWithAuth* = 1;
  https*  = 2; httpsWithAuth* = 3;
  gemini* = 4;
     git* = 5;
  unkn*   = -1;

VAR
  vpkConfDir-, vpkConfFile-, vpkTreeDir-, vpkPkgDir-, vpkDepDir-, vpkBldDir-,
  graphName-,
  rmtType-, rmtTypKey-, rmtTypGitVal-, rmtTypHttpVal-, rmtTypHttpsVal-,
  rmtTypGemiVal-, rmtTreeKey-, rmtTreeBranchKey-, rmtTreeTagKey-,
  rmtFiles-, rmtFileURL-, rmtFileAuthType-, rmtFileAuthCreds-, rmtFileMD5-,
  rmtFileAuthUsr-, rmtFileAuthPwd-,
  bldType-, bldCommand-, bldFile-,
  defTreeVal-, confTreeVal-,
  defTypVal-, pkgTypKey-, depTypKey-, packageFileName-,
  host-, port-: ARRAY 128 OF CHAR;

TYPE
  tree* = RECORD
   url* : ARRAY 128 OF CHAR;
   typ* : SHORTINT;
 branch*: ARRAY 128 OF CHAR;
   END;

BEGIN
  vpkConfDir   := ".vipack";
  vpkConfFile  := "vipackConf.json";
  vpkTreeDir   := "vipackTree";
  vpkPkgDir    := "vpkLocal";
  vpkDepDir    := "deps";
  vpkBldDir    := "build";

  graphName         := "deps.dot";

  rmtType           := "Remote";
  rmtTypKey         := "Type";
  rmtTypGitVal      := "git";
  rmtTypHttpVal     := "http";
  rmtTypHttpsVal    := "https";
  rmtTypGemiVal     := "gemini";
  rmtTreeKey        := "Path";
  rmtTreeBranchKey  := "Branch";
  rmtTreeTagKey     := "Tag";
  rmtFiles          := "Files";
  rmtFileURL        := "URL";
  rmtFileAuthType   := "AuthType";
  rmtFileAuthCreds  := "AuthCredentials";
  rmtFileAuthUsr    := "User";
  rmtFileAuthPwd    := "Password";
  rmtFileMD5        := "MD5";
  bldType           := "Build";
  bldCommand        := "Command";
  bldFile           := "File";
  defTreeVal        := "https://github.com/vishaps/vipackTree";
  (*defTreeVal      := "git@github.com:vishaps/vipackTree";*)
  confTreeVal       := defTreeVal;
  defTypVal         := rmtTypGitVal;

  pkgTypKey  := "Package";
  depTypKey  := "Dependencies";

  packageFileName := "VersionFile.json";
  host := "localhost";
  port := "80";

END vpkSettings.
