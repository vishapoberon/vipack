MODULE Vipack;
IMPORT  vpkGit, vpkConf, vpkLogger, vpkPackageFileParser, Texts, Strings, In, Platform, Oberon, Out, Files, vpkUserDetails;

PROCEDURE  main();

CONST confFileName = "vipack.conf";
CONST syncDirName = "tree/";

VAR  user, str: ARRAY 32 OF CHAR;
	 vpkDirPath, treePath, confPath : ARRAY 120 OF CHAR;
     i : INTEGER;
     f : Files.File;
     r : Files.Rider;
     ch : CHAR;
	 S: Texts.Scanner;
	 defaultUrl,gitUrl,project,command,string : ARRAY 500 OF CHAR;

PROCEDURE help();
BEGIN
	vpkLogger.Log("HelpText");
END help;


BEGIN
(* Getting 1 argument and outputting it *)
Texts.OpenScanner(S, Oberon.Par.text, Oberon.Par.pos);
Texts.Scan(S);
Out.String(S.s); Out.Ln;

defaultUrl := "https://github.com/norayr/diaspora";

command := S.s;

IF ~(Platform.getEnv("HOME", vpkDirPath)) THEN
	Out.String("HOME variable is not found"); Out.Ln;
END;

(*HELP*)
IF Strings.Match(command, "") OR Strings.Match(command, "--help")THEN
	help;
END;

Strings.Append("/.vipack/",vpkDirPath);
confPath := vpkDirPath;
treePath := vpkDirPath;

(* Checking if ~/.vipack directory already exists *)
IF vpkConf.makeDir(vpkDirPath) THEN 
	Out.String("Creating directory "); Out.String(vpkDirPath);Out.Ln;
ELSE Out.String(vpkDirPath); Out.String(" already exists or path is wrong");Out.Ln;
END;

(* Checking if vipack.conf already exists *)
Strings.Append(confFileName,confPath);

IF ~(vpkConf.confExists(confPath)) THEN
	Out.String("Creating the configuration file "); Out.String(confPath);Out.Ln;
	vpkConf.makeConf(confPath,f);
	Files.Set(r, f, 0);
	(*Files.WriteInt(r, 8)*); Files.WriteString(r, " PATH :"); Files.WriteString(r,defaultUrl);
	Files.Close(f);
ELSE 
	Out.String("File already exists");Out.Ln;
END;
(*after adding file and working with it, then removing the file part in the path *)


(*ELSIF Strings.Match(command, "install") THEN
	 vpkPackageFileParser.install();
END;*)



IF command = "sync" THEN
	Strings.Append(syncDirName, vpkDirPath);
	(*Check tree directory if doesn't exist create*)
	IF vpkConf.makeDir(treePath) THEN
		Out.String("Creating "); Out.String(treePath); Out.String("for syncing");Out.Ln;
	ELSE Out.String("Some error occured or directory already exist");
	END;
	(*Sync*)
	f := Files.Old(confPath);
	Files.Set(r,f,0);
	Files.ReadLine(r,gitUrl);
	Strings.Delete(gitUrl,0,6);
	Out.String(gitUrl); Out.Ln;
	string := gitUrl;
	Strings.Delete(string,19,Strings.Length(string)-17);
	Out.String(string);Out.Ln;
	IF Strings.Match(string,"https://github.com/") OR Strings.Match(string,"git://github.com/") THEN
	Out.String("YES"); Out.Ln;
	vpkGit.clone(gitUrl);
	END;
END;



IF command = "install" THEN
	Texts.Scan(S);
	project := S.s;
	Out.String(project);Out.Ln;
END;


END main;


BEGIN

main();

END Vipack.
