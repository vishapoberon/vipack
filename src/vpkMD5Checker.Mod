MODULE vpkMD5Checker;
IMPORT MD5 := ethMD5, Out, Files, Strings;

PROCEDURE checkMD5*(VAR filename, expectedMD5: ARRAY OF CHAR): BOOLEAN;
VAR
  result: BOOLEAN;
  F: Files.File; R: Files.Rider;
  ch: CHAR;
  input: POINTER TO ARRAY OF CHAR;
  i, fileLength: LONGINT;
  context: MD5.Context; digest: MD5.Digest; hexDigest: ARRAY 33 OF CHAR;
BEGIN
  result := FALSE;

  F := Files.Old(filename);
  IF F # NIL THEN
    Files.Set(R, F, 0);
    fileLength := Files.Length(F);
    NEW(input, fileLength+1);
    i := 0;
    REPEAT
      Files.Read(R, ch);
      input^[i] := ch;
      INC(i);
    UNTIL R.eof;
    context := MD5.New();
    MD5.WriteBytes(context, input^, LEN(input^)-1);
    MD5.Close(context, digest);
    MD5.ToString(digest, hexDigest);
    Out.String("MD5 hash of "); Out.String(filename); Out.String(":"); Out.Ln;
    Out.String(hexDigest); Out.Ln;
    Out.String("exected hash:"); Out.Ln;
    Out.String(expectedMD5); Out.Ln;
    IF hexDigest = expectedMD5 THEN result := TRUE; END;
  ELSE
    Out.String("file "); Out.String(filename); Out.String("not found"); Out.Ln;
    Out.String("unable to check md5 sum"); Out.Ln;
  END;
  RETURN result
END checkMD5;




END vpkMD5Checker.
