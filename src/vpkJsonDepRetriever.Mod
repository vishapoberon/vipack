MODULE vpkJsonDepRetriever;
IMPORT Strings, Out,
       List, StringList, strUtils, Json, vpkStorage, vpkSettings, vpkdepTree;

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
  k := NIL; v := NIL;
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
                  IF Json.ObjSelect(command, buildStep, cm) &
                     Json.ObjSelect(file, buildStep, fl) THEN
                    IF (command IS Json.Str) & (file IS Json.Str) THEN
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

PROCEDURE getURIandType*(VAR d: vpkdepTree.Tdep);
VAR
  jsonstr, errstr: strUtils.pstring;
  tree, singleValue, remoteValue: Json.Value;
  rootObj, someObj, remoteObj, fileObj, fileObj2, authObj: Json.Obj;
  filesArray, fileObjValue: Json.Value;
  fileValue, urlValue, authTypeValue, md5Value, authCredsValue, userValue, passwordValue: Json.Value;
  err: ARRAY ErrmessSize OF CHAR;
  b, fndRemSec, fndTypeHttps, fndFiles: BOOLEAN;
  key, val, u, t, br, remote,
    url, authType, authTypeStr,
    md5,  authCr, authCrStr,
    user, password : Json.jString;
    httpsRemote: vpkdepTree.RemoteHttps; gitRemote: vpkdepTree.RemoteGit;
    httpsFile: vpkdepTree.File;
BEGIN
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
        fndRemSec := FALSE;
        fndTypeHttps   := FALSE;
        REPEAT
          IF rootObj.name^ = remote^ THEN
            fndRemSec := TRUE;
          END;
          IF ~fndRemSec THEN rootObj := rootObj.next END
        UNTIL (rootObj = NIL) OR fndRemSec;

        IF fndRemSec THEN
          WHILE rootObj # NIL DO
            remoteValue := rootObj.value;
            IF remoteValue IS Json.Obj THEN
              singleValue := remoteValue(Json.Obj);

              IF singleValue IS Json.Obj THEN
                someObj := singleValue(Json.Obj);
                key := someObj.name;
                IF someObj.value IS Json.Str THEN
                  val := someObj.value(Json.Str).str;
                  IF key^ = vpkSettings.rmtTypKey THEN (* type *)
                    IF val^ = vpkSettings.rmtTypHttpsVal THEN

                      NEW(httpsRemote); d^.rmt := httpsRemote;
                      d^.Type := vpkSettings.https;
                      httpsRemote^.Files := List.Create();
                      d^.Type := vpkSettings.https;
                      WHILE singleValue # NIL DO
                        someObj := singleValue(Json.Obj);

                        IF someObj.value IS Json.Arr THEN

                          filesArray := someObj.value(Json.Arr);
                          WHILE filesArray # NIL DO
                            IF filesArray IS Json.Arr THEN
                              fileObjValue := filesArray(Json.Arr).value;
                                Out.Ln;
                              IF fileObjValue IS Json.Obj THEN
                                fileObj := fileObjValue(Json.Obj);
                                NEW(httpsFile);
                                httpsFile^.auth := FALSE; (* default *)
                                (* extract url *)
                                NEW(url, Strings.Length(vpkSettings.rmtFileURL)+1);
                                COPY(vpkSettings.rmtFileURL, url^);
                                IF Json.ObjSelect(urlValue, fileObj, url) & (urlValue IS Json.Str) THEN
                                  COPY(urlValue(Json.Str).str^, httpsFile^.URI);
                                END;
                                fileObj2 := fileObj;
                                (* extract authtype *)
                                NEW(authType, Strings.Length(vpkSettings.rmtFileAuthType)+1);
                                COPY(vpkSettings.rmtFileAuthType, authType^);
                                IF Json.ObjSelect(authTypeValue, fileObj2, authType)
                                   & (authTypeValue IS Json.Str) THEN
                                  authTypeStr := authTypeValue(Json.Str).str;
                                  IF authTypeValue(Json.Str).str^ = vpkSettings.rmtFileAuthValBasic THEN
                                    httpsFile^.auth := TRUE;
                                    (* extract auth credentials *)
                                    NEW(authCr, Strings.Length(vpkSettings.rmtFileAuthCreds)+1);
                                    COPY(vpkSettings.rmtFileAuthCreds, authCr^);
                                    IF Json.ObjSelect(authCredsValue, fileObj2, authCr) & (authCredsValue IS Json.Obj) THEN
                                      IF authCredsValue IS Json.Obj THEN
                                        authObj := authCredsValue(Json.Obj);
                                        NEW(user, Strings.Length(vpkSettings.rmtFileAuthUsr) + 1);
                                        COPY(vpkSettings.rmtFileAuthUsr, user^);
                                        IF Json.ObjSelect(userValue, authObj, user) & (userValue IS Json.Str) THEN
                                          COPY(userValue(Json.Str).str^, httpsFile^.username);
                                        END;
                                        NEW(password, Strings.Length(vpkSettings.rmtFileAuthPwd) + 1);
                                        COPY(vpkSettings.rmtFileAuthPwd, password^);
                                        IF Json.ObjSelect(passwordValue, authObj, password) & (passwordValue IS Json.Str) THEN
                                          COPY(passwordValue(Json.Str).str^, httpsFile^.password);
                                        END;
                                      END; (* if authcradsvalue is json.obj *)
                                    END; (* if json objselect authcredsval *)

                                  ELSE
                                    httpsFile^.auth := FALSE;
                                  END
                                END;
                                                                (* extract md5 *)
                                NEW(md5, Strings.Length(vpkSettings.rmtFileMD5)+1);
                                COPY(vpkSettings.rmtFileMD5, md5^);
                                IF Json.ObjSelect(md5Value, fileObj, md5) & (md5Value IS Json.Str) THEN
                                  COPY(md5Value(Json.Str).str^, httpsFile^.md5);
                                Out.String("found md5 "); Out.String(httpsFile^.md5); Out.Ln;
                                END;
                                httpsRemote^.Files.Append(httpsRemote^.Files, httpsFile);
                                (*Out.Int(d^.rmt(vpkdepTree.RemoteHttps)^.Files.Count, 0); Out.Ln;*)
                              END; (*fileobj is json.obj *)
                            END; (*filesarray is json arr *)
                            filesArray := filesArray(Json.Arr).next;
                          END; (* while filesarray # nil *)

                        END;
                        singleValue := someObj.next;
                      END;



                    ELSIF val^ = vpkSettings.rmtTypGitVal THEN
          NEW(gitRemote); d^.rmt := gitRemote;
          d^.Type := vpkSettings.git;
                      WHILE singleValue # NIL DO
                        IF singleValue IS Json.Obj THEN
                          someObj := singleValue(Json.Obj);
                          key := someObj.name;
                          val := someObj.value(Json.Str).str;
                          IF key^ = vpkSettings.rmtTreeBranchKey THEN
          COPY(val^, d^.rmt(vpkdepTree.RemoteGit)^.branch);
        END;
                          IF key^ = vpkSettings.rmtTreeKey THEN
          COPY(val^, d^.rmt^.URI);
                          END;
                        END;
                        singleValue := someObj.next;
                      END;
                    ELSE
                      Out.String("unhandled remote type"); Out.Ln; HALT(5);
                    END;
                  END;
                END;
              END; (* if single value is json.obj *)
            END; (* if remotevalue is json.obj *)

            rootObj := rootObj.next
          END; (* while rootObj # NIL *)
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
