MODULE vpkJsonDepRetriever;
IMPORT StringList, strutils, vpkJsonParser, vpkStorage, vpkSettings, vpkdepTree;


PROCEDURE getDeps*(VAR d: vpkdepTree.Tdep): StringList.TStringList;
VAR
  jsonRecord, dependencies: vpkJsonParser.JsonTypePointer;
  p: strutils.pstring;
  b: BOOLEAN;
  result: StringList.TStringList;
  pkgName : ARRAY 32 OF CHAR;
BEGIN
  result := NIL;
  p := NIL;
  vpkStorage.json2pstring(d.name^, p);
  IF p # NIL THEN
    jsonRecord := vpkJsonParser.Create(p^);
    b := jsonRecord.GetTerminal(jsonRecord, vpkSettings.pkgTypKey, pkgName);
    IF b THEN
      dependencies := NIL;
      dependencies := jsonRecord.GetNonTerminal(jsonRecord, vpkSettings.depTypKey);
      IF dependencies # NIL THEN
        dependencies.GetTerminalKeys(dependencies, result);
        RETURN result
      END
    END
  END;
  RETURN result
END getDeps;


END vpkJsonDepRetriever.
