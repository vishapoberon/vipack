MODULE Vipack;
IMPORT  vpkConf, vpkLogger, vpkPackageFileParser, Texts, Strings, In, Platform, Oberon, Out, Files, vpkUserDetails;

PROCEDURE  main();

CONST confFileName = "vipack.conf";
CONST syncDirName = "tree/";

VAR  user, str: ARRAY 32 OF CHAR;
	 confPath, curPath, string : ARRAY 120 OF CHAR;
     i : INTEGER;
     f : Files.File;
     r : Files.Rider;
     ch : CHAR;
	 S: Texts.Scanner;
	 defaultUrl,project,command : ARRAY 500 OF CHAR;

PROCEDURE help();
BEGIN
	vpkLogger.Log("HelpText");
END help;


BEGIN
(* Getting 1 argument and outputting it *)
Texts.OpenScanner(S, Oberon.Par.text, Oberon.Par.pos);
Texts.Scan(S);
Out.String(S.s); Out.Ln;

defaultUrl := "https://github.com/PizzaPablo666/test";

command := S.s;

confPath := "/home//.vipack/";

(*HELP*)
IF Strings.Match(command, "") OR Strings.Match(command, "--help")THEN
	help;
END;

(* Getting username from input if there is no $USER variable *)
IF ~(vpkUserDetails.GetUsername(user)) THEN
	 Out.String("username: "); In.Line(user); 
END;

(* Making the full path to vipack.conf *)
Strings.Insert(user,6,confPath);
Out.String(confPath);Out.Ln;
curPath := confPath;

(* Checking if ~/.vipack directory already exists *)
IF vpkConf.makeDir(confPath) THEN 
	Out.String("Creating directory "); Out.String(confPath);Out.Ln;
ELSE Out.String(confPath); Out.String(" already exists or path is wrong");Out.Ln;
END;

(* Checking if vipack.conf already exists *)
Strings.Append(confFileName,curPath);

IF ~(vpkConf.confExists(curPath)) THEN
	Out.String("Creating the configuration file "); Out.String(confPath);Out.Ln;
	vpkConf.makeConf(curPath,f);
	Files.Set(r, f, 0);
	Files.WriteInt(r, 8); Files.WriteString(r, " PATH :"); Files.WriteString(r,defaultUrl);
	Files.Close(f);
ELSE 
	Out.String("File already exists");Out.Ln;
END;
(*after adding file and working with it, then removing the file part in the path *)
curPath := confPath;


(*ELSIF Strings.Match(command, "install") THEN
	 vpkPackageFileParser.install();
END;*)



IF command = "sync" THEN
	Strings.Append(syncDirName, curPath);
	(*Check tree directory if doesn't exist create*)
	IF vpkConf.makeDir(curPath) THEN
		Out.String("Creating "); Out.String(curPath); Out.String("for syncing");Out.Ln;
	ELSE Out.String("Some error occured or directory already exist");
	END;
	(*Sync*)
	(*git.sync();*)
END;



IF command = "install" THEN
	Texts.Scan(S);
	project := S.s;
	Out.String(project);Out.Ln;
END;



Out.String(user); Out.Ln;
END main;


BEGIN

main();

END Vipack.
