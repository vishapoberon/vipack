MODULE vpkJsonDepRetriever;
IMPORT Out, StringList, strutils, vpkJsonParser, vpkStorage, vpkSettings, vpkdepTree;

PROCEDURE getBuildInfo*(VAR d: vpkdepTree.Tdep; VAR k, v: StringList.TStringList): BOOLEAN;
VAR
  p: strutils.pstring;
  jsonRecord, build : vpkJsonParser.JsonTypePointer;
  keys, values: StringList.TStringList;
  b: BOOLEAN;
BEGIN
  b := FALSE;
  p := NIL;
  vpkStorage.json2pstring(d.name^, p);
  IF p # NIL THEN
    jsonRecord := vpkJsonParser.Create(p^);
    build := jsonRecord.GetNonTerminal(jsonRecord, vpkSettings.bldType);
    IF build # NIL THEN
      keys := NIL; values := NIL;
      build.GetTerminalKeys(build, keys);
      build.GetTerminalValues(build, values);
      k := keys; v := values;
      RETURN TRUE
    ELSE
      RETURN FALSE
    END
  ELSE
    RETURN FALSE
  END;
END getBuildInfo;

PROCEDURE getURIandType*(VAR d: vpkdepTree.Tdep; VAR URI: ARRAY OF CHAR; VAR type: ARRAY OF CHAR; VAR branch: ARRAY OF CHAR);
VAR
  jsonRecord, remote: vpkJsonParser.JsonTypePointer;
  p: strutils.pstring;
  k, v: StringList.pstring;
  keys, values: StringList.TStringList;
  i: LONGINT;
BEGIN
  p := NIL;
  vpkStorage.json2pstring(d.name^, p);
  IF p # NIL THEN
    jsonRecord := vpkJsonParser.Create(p^);
    remote := jsonRecord.GetNonTerminal(jsonRecord, vpkSettings.rmtType);
    IF remote # NIL THEN
      keys := NIL; values := NIL;
      remote.GetTerminalKeys(remote, keys);
      remote.GetTerminalValues(remote, values);
      i := 0;
      REPEAT
        k := keys.GetString(keys, i);
        v := values.GetString(values, i);
        IF k^ = vpkSettings.rmtTypKey THEN COPY(v^, type) END; 
        IF k^ = vpkSettings.rmtTreeKey THEN COPY(v^, URI) END; 
        IF k^ = vpkSettings.rmtTreeBranchKey THEN COPY(v^, branch) END; 
        INC(i);
      UNTIL i = keys.Count - 1;
     ELSE
       Out.String("malformed json: no 'Remote' section"); Out.Ln;
       HALT(63);
     END
  ELSE
    Out.String("no json file for "); Out.String(d.name^); Out.Ln;
    Out.String("program is not expected to pass unexistent name, something is wrong in other module"); Out.Ln;
    HALT(64);
  END
END getURIandType;

(* returns -1 if no such dependency found, otherwise returns length of depstr string list *)
PROCEDURE getDeps*(VAR d: vpkdepTree.Tdep; VAR depstrlist: StringList.TStringList): LONGINT;
VAR
  jsonRecord, dependencies: vpkJsonParser.JsonTypePointer;
  p: strutils.pstring;
  b: BOOLEAN;
  pkgName : ARRAY 32 OF CHAR;
BEGIN
  depstrlist := NIL;
  p := NIL;
  vpkStorage.json2pstring(d.name^, p);
  IF p # NIL THEN
    jsonRecord := vpkJsonParser.Create(p^);
    b := jsonRecord.GetTerminal(jsonRecord, vpkSettings.pkgTypKey, pkgName);
    IF b THEN
      dependencies := NIL;
      Out.String("searching dependencies for '"); Out.String(d.name^); Out.String("'...   "); 
      dependencies := jsonRecord.GetNonTerminal(jsonRecord, vpkSettings.depTypKey);
      IF dependencies # NIL THEN
        Out.String("found!"); Out.Ln;
        dependencies.GetTerminalKeys(dependencies, depstrlist);
        StringList.list(depstrlist);
        RETURN depstrlist.Count
      ELSE
        Out.String("...has no dependencies"); Out.Ln;
        RETURN 0
      END
    ELSE
      RETURN -2 (* json doesn't contain 'Package' key, malformed *)
    END;
  ELSE
    RETURN -1 (* no such json file found *)
  END;
END getDeps;




END vpkJsonDepRetriever.
