MODULE vpkJsonDepRetriever;
IMPORT Strings, Out,
       StringList, strUtils, Json, vpkStorage, vpkSettings, vpkdepTree;

CONST
  ErrmessSize = 4096;

PROCEDURE getBuildInfo*(VAR d: vpkdepTree.Tdep; VAR k, v: StringList.TStringList): BOOLEAN;
VAR
  jsonstr, errstr: strUtils.pstring;
  tree, buildValue, command, file: Json.Value;
  rootObj, buildStep: Json.Obj;
  buildArray: Json.Arr;
  cm, fl, bl: Json.jString;
  b: BOOLEAN;
BEGIN
  b := FALSE;
  jsonstr := NIL;
  vpkStorage.json2pstring(d.name^, jsonstr);
  IF jsonstr # NIL THEN
    NEW(errstr, ErrmessSize);
    b := Json.Parse(tree, jsonstr^, errstr^);
    (*build := jsonRecord.GetNonTerminal(jsonRecord, vpkSettings.bldType);*)
    IF b THEN
      (*keys := NIL; values := NIL;
      build.GetTerminalKeys(build, keys);
      build.GetTerminalValues(build, values);
      k := keys; v := values;*)
        IF tree IS Json.Obj THEN
          rootObj := tree(Json.Obj);
          NEW(bl, Strings.Length(vpkSettings.bldType)+1); (* +1 for 0X *)
          COPY(vpkSettings.bldType, bl^);
          IF Json.ObjSelect(buildValue, rootObj, bl) THEN
            IF buildValue IS Json.Arr THEN
                buildArray := buildValue(Json.Arr);
                WHILE buildArray # NIL DO
                  buildStep := buildArray.value(Json.Obj);
                  NEW(cm, Strings.Length(vpkSettings.bldCommand)+1); (* +1 for 0X *)
                  NEW(fl, Strings.Length(vpkSettings.bldFile)+1);    (* +1 for 0X *)
                  COPY(vpkSettings.bldCommand, cm^);
                  COPY(vpkSettings.bldFile, fl^);
                       Out.String("cm^ is"); Out.String(cm^); Out.Ln;
                       Out.String("fl^ is"); Out.String(fl^); Out.Ln;
                  IF Json.ObjSelect(command, buildStep, cm) &
                     Json.ObjSelect(file, buildStep, fl) THEN
                        Out.String("COMMAND FOUND"); Out.Ln;
                             Out.String("FILE FOUND"); Out.Ln;
                    IF (command IS Json.Str) & (file IS Json.Str) THEN
                      Out.String("Command: "); Out.String(command(Json.Str).str^);
                      Out.String(", File: "); Out.String(file(Json.Str).str^); Out.Ln;
                      IF k = NIL THEN k := StringList.Create() END;
                      IF v = NIL THEN v := StringList.Create() END;
                      k.AppendString(k, command(Json.Str).str^);
                      v.AppendString(v, file(Json.Str).str^);
                    ELSE
                      Out.String("command and file must be strings"); Out.Ln;
                      HALT(5);
                    END;
                  END;
                  buildArray := buildArray.next;
                END;
            ELSE
              Out.String("Build section is not an array."); Out.Ln;
            END;
          ELSE
            Out.String("Build section not found."); Out.Ln;
          END;
        ELSE
          Out.String("JSON root is not an object."); Out.Ln;
        END;
    ELSE
        Out.String("JSON parsing failed: "); Out.String(errstr^); Out.Ln;
    END;
  END;
  RETURN b;
END getBuildInfo;
(*
PROCEDURE getURIandType*(VAR d: vpkdepTree.Tdep; VAR URI: ARRAY OF CHAR; VAR type: ARRAY OF CHAR; VAR branch: ARRAY OF CHAR);
VAR
  jsonRecord, remote: vpkJsonParser.JsonTypePointer;
  p: strUtils.pstring;
  k, v: StringList.pstring;
  keys, values: StringList.TStringList;
  i: LONGINT;
BEGIN
  strUtils.zeroStr(URI);
  strUtils.zeroStr(type);
  strUtils.zeroStr(branch);
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
*)

PROCEDURE getURIandType*(VAR d: vpkdepTree.Tdep; VAR URI: ARRAY OF CHAR; VAR type: ARRAY OF CHAR; VAR branch: ARRAY OF CHAR);
VAR
  jsonstr, errstr: strUtils.pstring;
  tree, remoteValue, uriValue, typeValue, branchValue: Json.Value;
  rootObj, remoteObj: Json.Obj;
  err: ARRAY ErrmessSize OF CHAR;
  b: BOOLEAN;
  u, t, br, remote: Json.jString;
BEGIN
  strUtils.zeroStr(URI);
  strUtils.zeroStr(type);
  strUtils.zeroStr(branch);
  jsonstr := NIL;
  vpkStorage.json2pstring(d.name^, jsonstr);
  IF jsonstr # NIL THEN
    NEW(errstr, ErrmessSize);
    b := Json.Parse(tree, jsonstr^, err);
    IF b THEN
      IF tree IS Json.Obj THEN
        rootObj := tree(Json.Obj);
        NEW(u, Strings.Length(vpkSettings.rmtTreeKey) + 1); COPY(vpkSettings.rmtTreeKey, u^);
        NEW(t, Strings.Length(vpkSettings.rmtTypKey) + 1); COPY(vpkSettings.rmtTypKey, t^);
        NEW(br, Strings.Length(vpkSettings.rmtTreeBranchKey) + 1); COPY(vpkSettings.rmtTreeBranchKey, br^);
        NEW(remote, Strings.Length(vpkSettings.rmtType)+1);
        COPY(vpkSettings.rmtType, remote^);
        IF Json.ObjSelect(remoteValue, rootObj, remote) THEN
                       Out.String("REMOTE FOUND"); Out.Ln;
          IF remoteValue IS Json.Obj THEN
            remoteObj := remoteValue(Json.Obj);
            IF Json.ObjSelect(uriValue, remoteObj, u) THEN
              IF uriValue IS Json.Str THEN
                COPY(uriValue(Json.Str).str^, URI);
                          Out.String("URI IS "); Out.String(uriValue(Json.Str).str^); Out.Ln;
              END;
            END;
            IF Json.ObjSelect(typeValue, remoteObj, t) THEN
              IF typeValue IS Json.Str THEN
                COPY(typeValue(Json.Str).str^, type);
                Out.String("TYPE VALUE "); Out.String(typeValue(Json.Str).str^);
                Out.Ln;
              END;
            END;
            IF Json.ObjSelect(branchValue, remoteObj, br) THEN
              IF branchValue IS Json.Str THEN
                COPY(branchValue(Json.Str).str^, branch);
                    Out.String("BRANCH ");
                    Out.String(branchValue(Json.Str).str^); Out.Ln;
              END;
            END;
          ELSE
            Out.String("Remote section is not an object."); Out.Ln;
          END;
        ELSE
          Out.String("Remote section not found."); Out.Ln;
        END;
      ELSE
        Out.String("JSON root is not an object."); Out.Ln;
      END;
    ELSE
      Out.String("JSON parsing failed: "); Out.String(err); Out.Ln;
    END;
  ELSE
    Out.String("No JSON string provided."); Out.Ln;
  END;
END getURIandType;

PROCEDURE getDeps*(VAR d: vpkdepTree.Tdep; VAR depstrlist: StringList.TStringList): LONGINT;
VAR
  jsonstr, errstr: strUtils.pstring;
  tree, depsValue, singleDep: Json.Value;
  rootObj, depObj: Json.Obj;
  depName, depVersion: Json.jString;
  foundDepSection: BOOLEAN;
BEGIN
  depstrlist := NIL;
  jsonstr := NIL;
  vpkStorage.json2pstring(d.name^, jsonstr);
  IF jsonstr # NIL THEN
    NEW(errstr, ErrmessSize);
    IF Json.Parse(tree, jsonstr^, errstr^) THEN
      IF tree IS Json.Obj THEN
        rootObj := tree(Json.Obj);   Out.String("entering first while"); Out.Ln;
        (* searching for dependencies section *)
        foundDepSection := FALSE;
        REPEAT
          IF rootObj.name^ = "Dependencies" THEN
            foundDepSection := TRUE;
            Out.String("dependency section found"); Out.Ln;
          END;
          IF ~foundDepSection THEN rootObj := rootObj.next END
        UNTIL (rootObj = NIL) OR foundDepSection;
        Out.String("exited the loop"); Out.Ln;
        IF foundDepSection THEN
          WHILE rootObj # NIL DO
                  Out.String("entered"); Out.Ln;
                  Out.String("rootobj.name "); Out.String(rootObj.name^); Out.Ln;
            (*IF rootObj.name^ = "Dependencies" THEN Out.String("yes name deps");Out.Ln;*)
              depsValue := rootObj.value;
              IF depsValue IS Json.Obj THEN Out.String("depsvalue is jsonobj"); Out.Ln;
                singleDep := depsValue(Json.Obj);
                WHILE singleDep # NIL DO
                  IF singleDep IS Json.Obj THEN Out.String("singledep is json obj"); Out.Ln;
                    depObj := singleDep(Json.Obj);
                    depName := depObj.name;
                    Out.String("name "); Out.String(depName^); Out.Ln;
                    Out.String("assigning depVersion"); Out.Ln;
                    depVersion := depObj.value(Json.Str).str;
                    Out.String("version "); Out.String(depVersion^); Out.Ln;
                    Out.String("assigning depstrlist"); Out.Ln;
                    IF depstrlist = NIL THEN depstrlist := StringList.Create() END;
                    depstrlist.AppendString(depstrlist, depName^);
                    Out.String("lets find next"); Out.Ln;
                    singleDep := depObj.next;  (* Move to the next dependency *)
                  END;
                END;  (* End of inner WHILE loop for dependencies *)
                Out.String("returning "); Out.Int(depstrlist.Count, 0); Out.Ln;
                RETURN depstrlist.Count;
              END;  (* End of IF depsValue IS Json.Obj *)
            (*END;*)  (* End of IF rootObj.name^ = "Dependencies" *)
            rootObj := rootObj.next;  (* Move to the next JSON object *)
          END;  (* End of WHILE rootObj # NIL loop *)
        ELSE
          Out.String("returnig 0"); Out.Ln;
          RETURN 0; (* found no dependencies *)
        END;
      END;  (* End of IF tree IS Json.Obj *)
    ELSE
      Out.String("JSON parsing failed: "); Out.String(errstr^); Out.Ln;
    END;  (* End of IF Json.Parse *)
  ELSE
    Out.String("dependency '"); Out.String(d.name^); Out.String("' not found."); Out.Ln;
    RETURN -1; (* No such JSON file found *)
  END;  (* End of IF jsonstr # NIL *)
  RETURN 0;
END getDeps;

END vpkJsonDepRetriever.
