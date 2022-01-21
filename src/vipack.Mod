MODULE vipack;
IMPORT  Texts, Strings, Oberon, Out,
  vpkConf, vpkLogger, vpkSyncer, vpkInstaller, vpkdepTree, opts, StringList;
(*
PROCEDURE processArgs(VAR package, prefix, tree: ARRAY OF CHAR; deps, sync: BOOLEAN);
VAR
    options: opts.Options;
   foptions: opts.Options;
  opt, fopt: opts.Option;
BEGIN

  options := opts.createOptions();
  foptions := opts.createOptions();

  opt := opts.createOpt();
  opts.setOptName(opt, "-p");
  opts.setOptLName(opt, "--package");
  opts.setOptHasVal(opt, TRUE);
  opts.setOptDesc(opt, "package name to download");
  opts.setOptRequired(opt, FALSE);
  options.add(options, opt);

  opt := opts.createOpt();
  opts.setOptName(opt, "-d");
  opts.setOptLName(opt, "--showdeps");
  opts.setOptHasVal(opt, FALSE);
  opts.setOptDesc(opt, "only resolve and show dependencies, do not fetch");
  opts.setOptRequired(opt, FALSE);
  options.add(options, opt);

  opts.setOptRequired(opt, FALSE);
  options.add(options, opt);

  opt := opts.createOpt();
  opts.setOptName(opt, "-s");
  opts.setOptLName(opt, "--sync");
  opts.setOptHasVal(opt, FALSE);
  opts.setOptDesc(opt, "sync the package tree");
  opts.setOptRequired(opt, FALSE);
  options.add(options, opt);

  opt := opts.createOpt();
  opts.setOptName(opt, "-P");
  opts.setOptLName(opt, "--prefix");
  opts.setOptHasVal(opt, TRUE);
  opts.setOptDesc(opt, "where to download and build packages");
  opts.setOptRequired(opt, FALSE);
  options.add(options, opt);

  opt := opts.createOpt();
  opts.setOptName(opt, "-t");
  opts.setOptLName(opt, "--tree");
  opts.setOptHasVal(opt, TRUE);
  opts.setOptDesc(opt, "override the default package description tree");
  opts.setOptRequired(opt, FALSE);
  options.add(options, opt);

  foptions := opts.populateOptions(options);
  IF opts.reqsSatisfied(options, foptions) THEN
    Out.String("required options provided"); Out.Ln;
  ELSE
    Out.String("required options not provided"); Out.Ln;
    opts.showHelp(options);
    HALT(3);
  END;
  Out.Ln;
  
  COPY("", package); COPY("", prefix); COPY("", tree);
  deps := FALSE; sync := FALSE;

  fopt := opts.createOpt();
  fopt := opts.findOpt("-d", foptions);
  IF fopt # NIL THEN deps := TRUE END;

   fopt := opts.createOpt();
   fopt := opts.findOpt("-s", foptions);
   IF fopt # NIL THEN sync := TRUE END;

 
  opts.valOfOpt("-p", foptions, package);
  opts.valOfOpt("-P", foptions, prefix);
  opts.valOfOpt("-t", foptions, tree);

END processArgs;
*)

PROCEDURE msgnopkg(VAR options: opts.Options);
BEGIN
      Out.String("you need to mention package name to resolve dependencies for it"); Out.Ln; Out.Ln;
      opts.showHelp(options);
END msgnopkg;

PROCEDURE main;
VAR
  deps, sync, fetch, ask: BOOLEAN;
  package, prefix, pkgTree: ARRAY 128 OF CHAR;
    
  options: opts.Options;
  foptions: opts.Options;
  opt, fopt: opts.Option;

  depTree: vpkdepTree.TdepTree;
BEGIN
  IF ~vpkConf.configured() THEN vpkConf.mkDefConfig END;

  options := opts.createOptions();
  foptions := opts.createOptions();

  opt := opts.createOpt();
  opts.setOptName(opt, "-p");
  opts.setOptLName(opt, "--package");
  opts.setOptHasVal(opt, TRUE);
  opts.setOptDesc(opt, "package name to download");
  opts.setOptRequired(opt, FALSE);
  options.add(options, opt);

  opt := opts.createOpt();
  opts.setOptName(opt, "-d");
  opts.setOptLName(opt, "--showdeps");
  opts.setOptHasVal(opt, FALSE);
  opts.setOptDesc(opt, "only resolve and show dependencies, do not fetch");
  opts.setOptRequired(opt, FALSE);
  options.add(options, opt);

  opt := opts.createOpt();
  opts.setOptName(opt, "-f");
  opts.setOptLName(opt, "--fetch");
  opts.setOptHasVal(opt, FALSE);
  opts.setOptDesc(opt, "only resolve and fetch, do not build");
  opts.setOptRequired(opt, FALSE);
  options.add(options, opt);

  opt := opts.createOpt();
  opts.setOptName(opt, "-a");
  opts.setOptLName(opt, "--ask");
  opts.setOptHasVal(opt, FALSE);
  opts.setOptDesc(opt, "only resolve and fetch, do not build");
  opts.setOptRequired(opt, FALSE);
  options.add(options, opt);

  opt := opts.createOpt();
  opts.setOptName(opt, "-s");
  opts.setOptLName(opt, "--sync");
  opts.setOptHasVal(opt, FALSE);
  opts.setOptDesc(opt, "sync the package tree");
  opts.setOptRequired(opt, FALSE);
  options.add(options, opt);

  opt := opts.createOpt();
  opts.setOptName(opt, "-P");
  opts.setOptLName(opt, "--prefix");
  opts.setOptHasVal(opt, TRUE);
  opts.setOptDesc(opt, "where to download and build packages");
  opts.setOptRequired(opt, FALSE);
  options.add(options, opt);

  opt := opts.createOpt();
  opts.setOptName(opt, "-t");
  opts.setOptLName(opt, "--tree");
  opts.setOptHasVal(opt, TRUE);
  opts.setOptDesc(opt, "override the default package description tree");
  opts.setOptRequired(opt, FALSE);
  options.add(options, opt);

  foptions := opts.populateOptions(options);
  IF opts.reqsSatisfied(options, foptions) THEN
    Out.String("required options provided"); Out.Ln;
  ELSE
    Out.String("required options not provided"); Out.Ln;
    opts.showHelp(options);
    HALT(3);
  END;
  Out.Ln;
  
  COPY("", package); COPY("", prefix); COPY("", pkgTree);
  deps := FALSE; sync := FALSE;

  fopt := opts.createOpt();
  fopt := opts.findOpt("-d", foptions);
  IF fopt # NIL THEN deps := TRUE END;

  fopt := opts.createOpt();
  fopt := opts.findOpt("-a", foptions);
  IF fopt # NIL THEN ask := TRUE END;


  fopt := opts.createOpt();
  fopt := opts.findOpt("-f", foptions);
  IF fopt # NIL THEN fetch := TRUE END;

  fopt := opts.createOpt();
  fopt := opts.findOpt("-s", foptions);
  IF fopt # NIL THEN sync := TRUE END;

 
  opts.valOfOpt("-p", foptions, package);
  opts.valOfOpt("-P", foptions, prefix);
  opts.valOfOpt("-t", foptions, pkgTree);

  IF pkgTree # "" THEN vpkConf.setTreeDir(pkgTree) END;

  IF sync THEN
    vpkSyncer.sync
  ELSE
    IF package # "" THEN
      IF deps THEN
        depTree := vpkInstaller.resolve(package)
      ELSIF fetch THEN
        vpkInstaller.fetch(package, prefix, pkgTree, ask)
      ELSE
        vpkInstaller.build(package, prefix, pkgTree, ask)
      END
    ELSE
      msgnopkg(options)
    END
  END;

END main;

(*
PROCEDURE help();
BEGIN
	vpkLogger.Log("HelpText");
	Out.String("Vipack sync - syncing git tree and local tree"); Out.Ln;
	Out.String("vipackConf.json path -> $HOME/.vipack/vipackConf.json"); Out.Ln;
	Out.String("vipackTree path -> $HOME/.vipack/vipackTree")
END help;

PROCEDURE  main();
VAR  
	S: Texts.Scanner;
  unit, command: ARRAY 64 OF CHAR; (* because Texts.Scanner.s is 64 bytes long*)
BEGIN
  (* this could go to vpkConf init section, 
  but here it is more visible. though may be it doesn't have to be *)
  IF ~vpkConf.configured() THEN vpkConf.mkDefConfig END; 

  (* Getting 1 argument and outputting it *)
  Texts.OpenScanner(S, Oberon.Par.text, Oberon.Par.pos);
  Texts.Scan(S);

  command := S.s;

  IF Strings.Match(command, "") OR Strings.Match(command, "help")THEN
	  help;
  ELSE 

    IF command = "sync" THEN
      vpkSyncer.sync;
	  END;

	  IF command = "install" THEN
		  Texts.Scan(S);
		  unit := S.s;
		  vpkInstaller.install(unit);
	  END;

  END;
END main;
*)

BEGIN
  main
END vipack.
