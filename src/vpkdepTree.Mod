MODULE vpkdepTree;
IMPORT Out, strutils, StringList;
TYPE
 
  pstring = strutils.pstring;
  pstrings = strutils.pstrings;

  Tdep*  = POINTER TO TdepDesc;
  Tdeps* = POINTER TO ARRAY OF Tdep;

  TdepTree* = POINTER TO TdepTreeDesc;

  TdepTreeDesc* = RECORD
     First- : Tdep;
      Last- : Tdep;
    Create* : PROCEDURE () : TdepTree;
      Free* : PROCEDURE (l : TdepTree);
     Clear* : PROCEDURE (l : TdepTree);
       Add* : PROCEDURE (l : TdepTree; s : Tdep);
       Get* : PROCEDURE (l : TdepTree; i : LONGINT): Tdep;
     Empty* : PROCEDURE (l : TdepTree) : BOOLEAN;
     Count* : LONGINT;
  END;

  TdepDesc* = RECORD
         prev-, next-: Tdep;
         name* : pstring;
         deps* : Tdeps;
       END;

PROCEDURE list(VAR s : StringList.TStringList);
VAR e : StringList.Node;
    i : INTEGER;
BEGIN
   NEW(e);
   i := 0;
   REPEAT
      e := s.Get(s, i);
      IF e # NIL THEN Out.String (e.obj(StringList.TString).str^); Out.Ln END;
      (*Out.String (e.string); Out.Ln;*)
      INC(i);
   UNTIL i = s.Count - 1;
END list;

PROCEDURE Free*(l : TdepTree);
 BEGIN
 END Free;

PROCEDURE Clear*(l : TdepTree);
 BEGIN
    l.First   := NIL;
    l.Count   := 0;
 END Clear;

PROCEDURE Empty* (l : TdepTree) : BOOLEAN;
 BEGIN
    RETURN l.First = NIL
 END Empty;

PROCEDURE Add* (l : TdepTree; d: Tdep);
 BEGIN
    IF l.First = NIL THEN
       l.First := d;
    ELSE
       l.Last.next := d;
    END;
    l.Last := d;
    INC(l.Count);
 END Add;

PROCEDURE Get*(l: TdepTree; inx: LONGINT): Tdep;
VAR
  i: LONGINT;
  d: Tdep;
BEGIN
  NEW(d); d := NIL;
  i := 0;
  IF (inx < l.Count) & (inx >= 0) THEN
    i := 0;
    d := l.First;
    WHILE i # inx DO
      IF d # NIL THEN d := d.next END;
      INC(i);
    END;
  END;
  RETURN d;
END Get;

PROCEDURE Create* () : TdepTree;
    VAR l : TdepTree;
 BEGIN
    NEW(l);
    l.First   := NIL;
    l.Last    := NIL;
    l.Count   := 0;
    l.Add     := Add;
    l.Get     := Get;
    l.Clear   := Clear;
    l.Free    := Free;
    l.Empty   := Empty;
    RETURN(l);
 END Create;


END vpkdepTree.