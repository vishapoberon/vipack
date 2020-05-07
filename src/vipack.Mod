MODULE vipack;
IMPORT  vpkFileManager,vpkJsonParser,vpkGit, vpkConf, vpkLogger, vpkPackageFileParser, Texts, Strings, In, Platform, Oberon, Out;

PROCEDURE  main();

CONST confFileName = "vipackConf.json";
CONST syncDirName = "vipackTree";
CONST quote = '"';
CONST startBracket = "{";
CONST endBracket = "}";

VAR  user, str: ARRAY 32 OF CHAR;
	 vpkDirPath, treePath, confPath, jsonString : ARRAY 120 OF CHAR;
     i : INTEGER;
     ch : CHAR;
	 S: Texts.Scanner;
 jsonData,string,defaultUrl,gitUrl,project,command, jsonPathLine : ARRAY 500 OF CHAR;
	 success: BOOLEAN;
	 jsonRecord: vpkJsonParser.JsonTypePointer;

PROCEDURE help();
BEGIN
	vpkLogger.Log("HelpText");
	Out.String("Vipack sync - syncing git tree and local tree"); Out.Ln;
	Out.String("vipackConf.json path -> $HOME/.vipack/vipackConf.son"); Out.Ln;
	Out.String("vipackTree path -> $HOME/.vipack/vipackTree")
END help;


BEGIN
(* Getting 1 argument and outputting it *)
Texts.OpenScanner(S, Oberon.Par.text, Oberon.Par.pos);
Texts.Scan(S);
Out.String(S.s); Out.Ln;

defaultUrl := "https://github.com/vishaps/vipackTree";

command := S.s;

IF Strings.Match(command, "") OR Strings.Match(command, "help")THEN
	help;
ELSE 

	IF ~(vpkConf.varCheck("HOME", vpkDirPath)) THEN
		Out.String("HOME variable is not found"); Out.Ln;
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
		jsonPathLine := "";
		vpkConf.makeFile(confPath);
		Strings.Append(startBracket, jsonPathLine);
		Strings.Append('"path" : ', jsonPathLine);
		Strings.Append(quote, jsonPathLine);
		Strings.Append(defaultUrl,jsonPathLine);
		Strings.Append(quote, jsonPathLine);
		Strings.Append(endBracket,jsonPathLine);
		vpkConf.writeInFile(confPath,jsonPathLine,0);
	ELSE 
		Out.String("File already exists");Out.Ln;
	END;


	IF command = "sync" THEN
		treePath := vpkDirPath;
		Strings.Append(syncDirName, treePath);
		Strings.Append("/",treePath);
		Out.String("*****************************************"); Out.Ln;
		Out.String("TreePath = "); Out.String(treePath);

		(* Check tree directory if doesn't exist create*)
		IF vpkConf.makeDir(treePath) THEN
			Out.String("Creating "); Out.String(treePath); Out.String("for syncing");Out.Ln;
		ELSE Out.String("Some error occured or directory already exist");
		END;
		(* Syncing *)
		success := vpkFileManager.Read(confPath,jsonData);
		jsonRecord := vpkJsonParser.Create(jsonData);
		success := vpkJsonParser.GetTerminal(jsonRecord,"path", jsonString);
		Out.String("URL = ");
		Out.String(jsonString);Out.Ln;
		gitUrl := jsonString;
		string := gitUrl;
		Strings.Delete(string,19,Strings.Length(string)-17);
		Out.String(string);Out.Ln;
		(* Checking the URL of vipackConf.json path key *)
		IF Strings.Match(string,"https://github.com/") OR Strings.Match(string,"git://github.com/") THEN
		Out.String("YES"); Out.Ln;
		vpkGit.pull(gitUrl,treePath);
		END;
	END;



	IF command = "install" THEN
		Texts.Scan(S);
		project := S.s;
		Out.String(project);Out.Ln;
		vpkPackageFileParser.install();

	END;

END;
END main;


BEGIN

main();

END vipack.
