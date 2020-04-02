MODULE Vipack;
IMPORT vpkLogger, vpkPackageFileParser,Texts,Strings,In,Platform, Oberon, Out, Files, vpkUserDetails;

PROCEDURE  main();
VAR  user, str, fn: ARRAY 32 OF CHAR;
	 confDir, string : ARRAY 120 OF CHAR;
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


(* Vipack installation or help) *)
command := S.s;
IF Strings.Match(command, "") OR Strings.Match(command, "--help")THEN
	help;
ELSIF Strings.Match(command, "install") THEN
	 vpkPackageFileParser.install();
END;


confDir := "/home//.vipack/vipack.conf";

(* Getting username from input if there is no $USER variable *)
IF ~(vpkUserDetails.GetUsername(user)) THEN
	 Out.String("username: "); In.Line(user); 
END;

(* Making the full path to vipack.conf *)
Strings.Insert(user,6,confDir);
Out.String(confDir);Out.Ln;

(* Checking if vipack.conf already exists *)
IF Files.Old(confDir) = NIL THEN
		Out.String("Creating the configuration file "); Out.String(confDir);Out.Ln; 
		f := Files.New(confDir);
		Files.Set(r, f, 0);
		Files.WriteInt(r, 8); Files.WriteString(r, "Configuration");
		Files.Register(f);
ELSIF Files.Old(confDir) # NIL THEN 
	Out.String("File already exists");Out.Ln;
END;

Out.String(user); Out.Ln;
END main;


BEGIN

main();

END Vipack.
