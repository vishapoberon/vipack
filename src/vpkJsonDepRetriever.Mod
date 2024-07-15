MODULE vpkJsonDepRetriever;
IMPORT Strings, Out,
       List, StringList, strUtils, Json, vpkStorage, vpkSettings, vpkdepTree;

CONST
  ErrmessSize = 4096;

PROCEDURE ToLower(VAR stringVar: ARRAY OF CHAR);
VAR
  i: INTEGER;
BEGIN
  i := 0;
  WHILE stringVar[i] # 0X DO
    IF (stringVar[i] >= "A") & (stringVar[i] <= "Z") THEN
      stringVar[i] := CHR(ORD(stringVar[i]) + 20H);
    END;
    INC(i);
  END;
END ToLower;


PROCEDURE getBuildInfo*(VAR d: vpkdepTree.Tdep; VAR k, v: StringList.TStringList): BOOLEAN;
VAR
  jsonstr, errstr: strUtils.pstring;
  tree, buildValue, command, file: Json.Value;
  rootObj, buildStep: Json.Obj;
  buildArray: Json.Arr;
  cm, fl, bl, cmLower, flLower: Json.jString;
  b: BOOLEAN;
BEGIN
  k := NIL; v := NIL;
  b := FALSE;
  jsonstr := NIL;
  vpkStorage.json2pstring(d.name^, jsonstr);
  IF jsonstr # NIL THEN
    NEW(errstr, ErrmessSize);
    b := Json.Parse(tree, jsonstr^, errstr^);
    IF b THEN
      IF tree IS Json.Obj THEN
        rootObj := tree(Json.Obj);
        NEW(bl, Strings.Length(vpkSettings.bldType) + 1); (* +1 for 0X *)
        COPY(vpkSettings.bldType, bl^);
        IF Json.ObjSelect(buildValue, rootObj, bl) THEN
          IF buildValue IS Json.Arr THEN
            buildArray := buildValue(Json.Arr);
            WHILE buildArray # NIL DO
              buildStep := buildArray.value(Json.Obj);
              Out.String("Examining build step object"); Out.Ln;
              IF buildStep # NIL THEN
                Out.String("buildStep keys: "); 
                rootObj := buildStep;
                WHILE rootObj # NIL DO
                  Out.String(rootObj.name^); Out.String(" "); 
                  rootObj := rootObj.next;
                END;
                Out.Ln;
              ELSE
                Out.String("buildStep is NIL"); Out.Ln;
              END;

              NEW(cm, Strings.Length(vpkSettings.bldCommand) + 1); (* +1 for 0X *)
              NEW(fl, Strings.Length(vpkSettings.bldFile) + 1);    (* +1 for 0X *)
              COPY(vpkSettings.bldCommand, cm^);
              COPY(vpkSettings.bldFile, fl^);

              NEW(cmLower, Strings.Length(cm^) + 1);
              NEW(flLower, Strings.Length(fl^) + 1);
              COPY(cm^, cmLower^);
              COPY(fl^, flLower^);
              ToLower(cmLower^);
              ToLower(flLower^);

              IF Json.ObjSelect(command, buildStep, cmLower) THEN
                Out.String("Selected command: "); Out.String(command(Json.Str).str^); Out.Ln;
                IF Json.ObjSelect(file, buildStep, flLower) THEN
                  Out.String("Selected file: "); Out.String(file(Json.Str).str^); Out.Ln;
                  IF (command IS Json.Str) & (file IS Json.Str) THEN
                    IF k = NIL THEN k := StringList.Create() END;
                    IF v = NIL THEN v := StringList.Create() END;
                    k.AppendString(k, command(Json.Str).str^);
                    v.AppendString(v, file(Json.Str).str^);
                    Out.String("Appended command: "); Out.String(command(Json.Str).str^); Out.Ln;
                    Out.String("Appended file: "); Out.String(file(Json.Str).str^); Out.Ln;
                  ELSE
                    Out.String("Command and file must be strings"); Out.Ln;
                    HALT(5);
                  END;
                ELSE
                  Out.String("Failed to select 'file' from build step"); Out.Ln;
                END;
              ELSE
                Out.String("Failed to select 'command' from build step"); Out.Ln;
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
  ELSE
    Out.String("No JSON string provided."); Out.Ln;
  END;
  RETURN b;
END getBuildInfo;


PROCEDURE getURIandType*(VAR d: vpkdepTree.Tdep);
VAR
  jsonstr, errstr: strUtils.pstring;
  tree, remoteValue: Json.Value;
  rootObj, someObj: Json.Obj;
  err: ARRAY ErrmessSize OF CHAR;
  b, fndRemSec: BOOLEAN;
  key, val, remote, keyLower: Json.jString;
  httpsRemote: vpkdepTree.RemoteHttps;
  gitRemote: vpkdepTree.RemoteGit;
BEGIN
  jsonstr := NIL;
  vpkStorage.json2pstring(d.name^, jsonstr);
  IF jsonstr # NIL THEN
    NEW(errstr, ErrmessSize);
    b := Json.Parse(tree, jsonstr^, err);
    IF b THEN
      IF tree IS Json.Obj THEN
        rootObj := tree(Json.Obj);
        NEW(remote, Strings.Length(vpkSettings.rmtType) + 1);
        COPY(vpkSettings.rmtType, remote^);
        fndRemSec := FALSE;

        (* Find the "Remote" section *)
        WHILE (rootObj # NIL) & ~fndRemSec DO
          NEW(keyLower, LEN(rootObj.name^) + 1);
          COPY(rootObj.name^, keyLower^);
          ToLower(keyLower^);
          IF keyLower^ = "remote" THEN
            fndRemSec := TRUE;
          ELSE
            rootObj := rootObj.next;
          END;
        END;

        IF fndRemSec THEN
          Out.String("Found 'Remote' section"); Out.Ln;
          remoteValue := rootObj.value;
          IF remoteValue IS Json.Obj THEN
            rootObj := remoteValue(Json.Obj);
            (* Process the "Remote" object *)
            WHILE rootObj # NIL DO
              key := rootObj.name;
              (* Convert key to lowercase *)
              NEW(keyLower, LEN(key^) + 1);
              COPY(key^, keyLower^);
              ToLower(keyLower^);
              IF rootObj.value IS Json.Str THEN
                val := rootObj.value(Json.Str).str;
                Out.String("Processing key: "); Out.String(key^); Out.Ln;
                Out.String("Value: "); Out.String(val^); Out.Ln;
                IF keyLower^ = "type" THEN (* type *)
                  IF val^ = vpkSettings.rmtTypHttpsVal THEN
                    NEW(httpsRemote); d^.rmt := httpsRemote;
                    d^.Type := vpkSettings.https;
                    Out.String("Set remote type to HTTPS"); Out.Ln;
                  ELSIF val^ = vpkSettings.rmtTypGitVal THEN
                    NEW(gitRemote); d^.rmt := gitRemote;
                    d^.Type := vpkSettings.git;
                    gitRemote^.branch[0] := 0X; (* Ensure branch is set to an empty string *)
                    Out.String("Set remote type to GIT"); Out.Ln;
                  ELSE
                    Out.String("Unhandled remote type: "); Out.String(val^); Out.Ln; HALT(5);
                  END;
                ELSIF keyLower^ = "tag" THEN
                  IF d^.rmt # NIL THEN
                    COPY(val^, d^.rmt(vpkdepTree.RemoteGit)^.tag); (* Use the tag field appropriately *)
                    Out.String("Set tag to "); Out.String(val^); Out.Ln;
                  ELSE
                    Out.String("d^.rmt is NIL when setting tag"); Out.Ln;
                  END;
                ELSIF keyLower^ = "path" THEN
                  IF d^.rmt # NIL THEN
                    COPY(val^, d^.rmt^.URI);
                    Out.String("Set URI to "); Out.String(val^); Out.Ln;
                  ELSE
                    Out.String("d^.rmt is NIL when setting URI"); Out.Ln;
                  END;
                ELSE
                  Out.String("Unhandled key: "); Out.String(key^); Out.Ln;
                END;
              ELSE
                Out.String("Value for key "); Out.String(key^); Out.String(" is not a string"); Out.Ln;
              END;
              rootObj := rootObj.next;
            END;
          ELSE
            Out.String("Remote value is not an object"); Out.Ln;
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
  IF d^.rmt = NIL THEN
    Out.String("deps remote is not set, this should not happen"); Out.Ln;
    HALT(5);
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
        rootObj := tree(Json.Obj);
        (* searching for dependencies section *)
        foundDepSection := FALSE;
        REPEAT
          IF rootObj.name^ = vpkSettings.depTypKey THEN
            foundDepSection := TRUE;
          END;
          IF ~foundDepSection THEN rootObj := rootObj.next END
        UNTIL (rootObj = NIL) OR foundDepSection;
        IF foundDepSection THEN
          WHILE rootObj # NIL DO
              depsValue := rootObj.value;
              IF depsValue IS Json.Obj THEN
                singleDep := depsValue(Json.Obj);
                WHILE singleDep # NIL DO
                  IF singleDep IS Json.Obj THEN
                    depObj := singleDep(Json.Obj);
                    depName := depObj.name;
                    depVersion := depObj.value(Json.Str).str;
                    IF depstrlist = NIL THEN depstrlist := StringList.Create() END;
                    depstrlist.AppendString(depstrlist, depName^);
                    singleDep := depObj.next;  (* Move to the next dependency *)
                  END;
                END;  (* End of inner WHILE loop for dependencies *)
                RETURN depstrlist.Count;
              END;  (* End of IF depsValue IS Json.Obj *)
            rootObj := rootObj.next;  (* Move to the next JSON object *)
          END;  (* End of WHILE rootObj # NIL loop *)
        ELSE
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
