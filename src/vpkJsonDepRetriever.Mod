MODULE vpkJsonDepRetriever;
IMPORT Out, StringList, strutils, vpkJsonParser, vpkStorage, vpkSettings, vpkdepTree;

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
        RETURN depstrlist.Count
      ELSE
        Out.String("...has no dependencies"); Out.Ln;
        RETURN 0
      END
    ELSE
      RETURN -2 (* json doesn't contain 'type' key, malformed *)
    END;
  ELSE
    RETURN -1 (* no such json file found *)
  END;
END getDeps;


END vpkJsonDepRetriever.
