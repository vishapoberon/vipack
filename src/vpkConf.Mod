MODULE vpkConf;
IMPORT Out, Files, Strings, Platform,
       vpkSettings, vpkEnv, vpkJsonParser;

CONST
   open = '{"';
  close = '"}';
     is = '": "';
 newkey = '", "';

PROCEDURE mkConfContent(VAR path: ARRAY OF CHAR);
(* constructing the line like:
{"path" : "https://github.com/vishaps/vipackTree"}, "type" : "git"}
*)
BEGIN
  COPY("", path);
  Strings.Append(open,  path);
  Strings.Append(vpkSettings.confTreeKey, path);
  Strings.Append(is,    path);
  Strings.Append(vpkSettings.defTreeVal,   path);
  Strings.Append(newkey, path);
  Strings.Append(vpkSettings.confTypKey,   path);
  Strings.Append(is,    path);
  Strings.Append(vpkSettings.defTypVal,    path);
  Strings.Append(close, path);
END mkConfContent;

PROCEDURE mkDefConfig*;
VAR
  content: ARRAY 96 OF CHAR;
  f: Files.File;
  r: Files.Rider;
BEGIN
    vpkEnv.checkEnv;
    f := vpkEnv.getConfFile();
    Files.Set(r, f, 0);
    mkConfContent(content);
    Files.WriteBytes(r, content, Strings.Length(content));
    Files.Register(f);
    Files.Close(f);
END mkDefConfig;

PROCEDURE configured*(): BOOLEAN;
BEGIN
  RETURN vpkEnv.checkConfig()
END configured;

PROCEDURE getConfigTreeVal*(VAR tree: vpkSettings.tree);
VAR
  f: Files.File; r: Files.Rider;
  dt: ARRAY 256 OF CHAR;
  i : INTEGER; ch: CHAR;
  jsonRecord : vpkJsonParser.JsonTypePointer;
  b: BOOLEAN;
  treeTyp: ARRAY 8 OF CHAR;
BEGIN
  f := vpkEnv.getConfFile();
  Files.Set(r, f, 0);
  i := 0;
  WHILE ~ r.eof & (i < LEN(dt)) DO Files.Read(r, ch); dt[i] := ch; INC(i) END;
  Files.Close(f);
  jsonRecord := vpkJsonParser.Create(dt);
  b := vpkJsonParser.GetTerminal(jsonRecord, vpkSettings.confTreeKey, tree.url);
  IF ~b THEN Out.String("unable to read "); Out.String (vpkSettings.confTreeKey); Out.String(" from json"); Out.Ln; HALT(1); END;
  b := vpkJsonParser.GetTerminal(jsonRecord, vpkSettings.confTypKey, treeTyp);
  IF ~b THEN Out.String("unable to read "); Out.String (vpkSettings.confTypKey); Out.String(" from json"); Out.Ln; HALT(1); END;
  IF treeTyp = vpkSettings.confTypGitVal THEN
    tree.typ := vpkSettings.git;
  ELSIF treeTyp = vpkSettings.confTypHttpVal THEN
    tree.typ := vpkSettings.http
  ELSE
    tree.typ := vpkSettings.unkn;
  END;
END getConfigTreeVal;

END vpkConf.
