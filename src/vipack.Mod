MODULE vipack;
IMPORT  Texts, Strings, Oberon, Out,
  vpkJsonParser, vpkGit, vpkConf, vpkLogger, vpkPackageFileParser, vpkSyncer;

PROCEDURE help();
BEGIN
	vpkLogger.Log("HelpText");
	Out.String("Vipack sync - syncing git tree and local tree"); Out.Ln;
	Out.String("vipackConf.json path -> $HOME/.vipack/vipackConf.son"); Out.Ln;
	Out.String("vipackTree path -> $HOME/.vipack/vipackTree")
END help;

PROCEDURE  main();
VAR  
  user, str: ARRAY 32 OF CHAR;
  i : INTEGER;
  ch : CHAR;
	S: Texts.Scanner;
  project, command: ARRAY 500 OF CHAR;
	jsonRecord: vpkJsonParser.JsonTypePointer;
BEGIN
  (* Getting 1 argument and outputting it *)
  Texts.OpenScanner(S, Oberon.Par.text, Oberon.Par.pos);
  Texts.Scan(S);
  Out.String(S.s); Out.Ln;

  command := S.s;

  IF Strings.Match(command, "") OR Strings.Match(command, "help")THEN
	  help;
  ELSE 
    vpkConf.configure;
	  IF command = "sync" THEN
      vpkSyncer.sync;
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
