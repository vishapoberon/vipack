MODULE Vipack;
IMPORT Texts,Strings,In,Platform, Oberon, Out, Files, UserDetails;

VAR  user, str, fn: ARRAY 32 OF CHAR;
	 confDir, string : ARRAY 120 OF CHAR;
     i : INTEGER;
     f : Files.File;
     r : Files.Rider;
     ch : CHAR;
	 S: Texts.Scanner;
BEGIN
(* Getting 1 argument and outputting it *)
Texts.OpenScanner(S, Oberon.Par.text, Oberon.Par.pos);
Texts.Scan(S);
Out.String(S.s); Out.Ln;

confDir := "/home//.vipack/vipack.conf";

(* Getting username from input if there is no $USER variable *)
IF ~(UserDetails.GetUsername(user)) THEN
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


END Vipack.
