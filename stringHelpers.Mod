MODULE stringHelpers; (*noch 18.5.2017 / 18.5.2017*)
IMPORT Strings := ooc2Strings;

CONST
  CR* = 0DX;
  LF* = 0AX;

(** feels whole array with zeroes, useful when one needs to get several strings which contain characters < ' ' and not necessarily end with 0X *)
PROCEDURE zeroStr*(VAR str: ARRAY OF CHAR);
VAR
  i, j : LONGINT;
BEGIN
  i := LEN(str);
  j := 0;
  REPEAT
    str[j] := 0X;
    INC(j)
  UNTIL j = i;
END zeroStr;

PROCEDURE appendLFCR*(VAR str: ARRAY OF CHAR);
VAR
  l : INTEGER;
BEGIN
        l := Strings.Length(str);
        str[l] := LF;
        str[l+1] := CR;
        str[l+2] := 0X;
END appendLFCR;

PROCEDURE findChar*(ch: CHAR; VAR line: ARRAY OF CHAR; VAR b: BOOLEAN; VAR pos: INTEGER);
VAR
  i : INTEGER;
BEGIN
  i := -1; pos := -1;
  b := FALSE;
  REPEAT
    INC(i);
    IF line[i] = ch THEN b := TRUE; pos := i END;
  UNTIL b OR (i = LEN(line) - 1);
END findChar;

(* cuts line, takes the part till the eol *)
PROCEDURE cutLine*(VAR src, dst: ARRAY OF CHAR);
VAR
 found: BOOLEAN;
 pos : INTEGER;
 i : INTEGER;
BEGIN
  COPY("", dst);
  findChar(LF, src, found, pos);
  IF found THEN
    i := 0;
    REPEAT
      dst[i] := src[i];
      INC(i);
    UNTIL (i = pos) OR (i = LEN(dst)-2);
    dst[i] := src[i];
    dst[i+1] := 0X
  END;
END cutLine;

(* put 0X after eol in the string *)
PROCEDURE terminateLine*(VAR str: ARRAY OF CHAR);
VAR
 found: BOOLEAN;
 pos : INTEGER;
BEGIN
  findChar(LF, str, found, pos);
  IF found THEN
    IF (pos + 1) < LEN(str) THEN
      str[pos + 1] := 0X
    END
  END;
END terminateLine;

PROCEDURE getTillEOL*(VAR src: ARRAY OF CHAR; spos: INTEGER; VAR dst: ARRAY OF CHAR); (* actually get till any character < ' ' *)
VAR
  i, j: INTEGER;
BEGIN
  zeroStr(dst);
  i := 0;
  j := spos+1;
  REPEAT
    dst[i] := src[i+j];
  INC(i);
  UNTIL (i+j = Strings.Length(src)) OR (src[i+j] < ' ');
END getTillEOL;

(* get next word starting from spos till the ' ' *)
PROCEDURE getNextWord*(VAR src: ARRAY OF CHAR; spos: INTEGER; VAR dst: ARRAY OF CHAR);
VAR
  i, j: INTEGER;
BEGIN
  zeroStr(dst);
  i := 0;
  j := spos+1;
  REPEAT
    dst[i] := src[i+j];
  INC(i);
  UNTIL (i+j = Strings.Length(src)) OR (src[i+j] <= ' ');
END getNextWord;

PROCEDURE contains* (VAR line : ARRAY OF CHAR; pattern: ARRAY OF CHAR): BOOLEAN;
VAR
 found: BOOLEAN;
 pos : INTEGER;
 i : INTEGER;
 patternLength: INTEGER;
 tmpline: POINTER TO ARRAY OF CHAR;
BEGIN
  i := 0;
  patternLength := Strings.Length(pattern);
  NEW(tmpline, patternLength+1);
  found := FALSE;
  REPEAT
    Strings.Extract(line, i, patternLength, tmpline^);
    found := Strings.Equal(pattern, tmpline^);
    INC(i);
UNTIL found OR (i = LEN(line) - patternLength - 1);
  IF found THEN RETURN TRUE ELSE RETURN FALSE END
END contains;


END stringHelpers.
