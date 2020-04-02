MODULE Vipack;
IMPORT  vpkConf, vpkFsHelper, vpkLogger, vpkPackageFileParser, Texts, Strings, In, Platform, Oberon, Out, Files, vpkUserDetails;

PROCEDURE  main();

CONST confFileName = "/vipack.conf";

VAR  user, str, fn: ARRAY 32 OF CHAR;
	 confPath, string : ARRAY 120 OF CHAR;
     i : INTEGER;
     f : Files.File;
     r : Files.Rider;
     ch : CHAR;
	 S: Texts.Scanner;
	 command : ARRAY 500 OF CHAR;

PROCEDURE help();
BEGIN
	vpkLogger.Log("HelpText");
END help;

BEGIN
(* Getting 1 argument and outputting it *)
Texts.OpenScanner(S, Oberon.Par.text, Oberon.Par.pos);
Texts.Scan(S);
Out.String(S.s); Out.Ln;


(* Vipack installation or help *)
command := S.s;
IF Strings.Match(command, "") OR Strings.Match(command, "--help")THEN
	help;
ELSIF Strings.Match(command, "install") THEN
	 vpkPackageFileParser.install();
END;


confPath := "/home//.vipack";

(* Getting username from input if there is no $USER variable *)
IF ~(vpkUserDetails.GetUsername(user)) THEN
	 Out.String("username: "); In.Line(user); 
END;

(* Making the full path to vipack.conf *)
Strings.Insert(user,6,confPath);
Out.String(confPath);Out.Ln;

(* Checking if ~/.vipack directory already exists *)
IF ~(vpkFsHelper.mkDir(confPath)) THEN 
	Out.String(confPath); Out.String(" already exists or path is wrong");Out.Ln;
ELSE Out.String("Creating directory "); Out.String(confPath);Out.Ln;
END;

(* Checking if vipack.conf already exists *)
Strings.Append(confFileName,confPath);

IF ~(vpkConf.confExists(confPath)) THEN
		Out.String("Creating the configuration file "); Out.String(confPath);Out.Ln; 
		vpkConf.makeConf(confPath);
ELSE 
	Out.String("File already exists");Out.Ln;
END;

Out.String(user); Out.Ln;
END main;


BEGIN

main();

END Vipack.
