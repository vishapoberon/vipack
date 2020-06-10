MODULE vpkResolver;
IMPORT Out, Strings, StringList, vpkdepTree, vpkRetriever;

TYPE
   Tdep = vpkdepTree.Tdep;
  Tdeps = vpkdepTree.Tdeps;

  TdepTree = vpkdepTree.TdepTree;

PROCEDURE treeContains(VAR d: Tdep; VAR depTree: TdepTree): BOOLEAN;
VAR
  res: BOOLEAN;
  i: INTEGER;
  d2: Tdep;
BEGIN
  res := FALSE;
  i := 0;
  REPEAT
    Out.Int(i, 0); Out.Ln;
    d2 := depTree.Get(depTree, i);
    IF d2 # NIL THEN
      IF d = d2 THEN res := TRUE END;
      (*IF d.name^ = d2.name^ THEN res := TRUE END *)
    END;
    INC(i)
  UNTIL res OR (i >= depTree.Count);
  RETURN res;
END treeContains;

PROCEDURE mkDepTree(VAR d: Tdep; VAR depTree, met: TdepTree);
VAR
  depStrs: StringList.TStringList;
  t: Tdep;
  deps: Tdeps;
  e: StringList.Node;
  i: INTEGER;
BEGIN
  met.Add(met, d);

    depStrs := vpkRetriever.getDeps(d.name^); 
    IF depStrs # NIL THEN
      NEW (deps, depStrs.Count);
      d.deps := deps;
      i := 0;
      REPEAT
        e := depStrs.Get(depStrs, i);
        IF e # NIL THEN
          t := met.GetByName(met, e.obj(StringList.TString).str^);
          IF t = NIL THEN
            NEW(t); NEW(t.name, Strings.Length(e.obj(StringList.TString).str^)+1);
            COPY (e.obj(StringList.TString).str^, t.name^);
          END;
          deps[i] := t;
          IF ~treeContains(t, depTree) THEN
            IF treeContains(t, met) THEN
              Out.String("curcular dependency!"); Out.Ln;
              Out.String(d.name^); Out.String(" requires "); Out.String(t.name^); Out.Ln;
              HALT(60)
            ELSE
              mkDepTree(t, depTree, met)
            END;
          END;
        END;
        INC(i) 
      UNTIL i = depStrs.Count - 1;
    END;
  depTree.Add(depTree, d);
END mkDepTree;

PROCEDURE resolve*(first: ARRAY OF CHAR): TdepTree;
VAR
  depTree: TdepTree;
  met: TdepTree;
  dep:  Tdep;
BEGIN
  depTree := vpkdepTree.Create();
  met := vpkdepTree.Create(); (* for deps that we already met *)
  NEW(dep); NEW(dep.name, Strings.Length(first) + 1);
  COPY(first, dep.name^);
  mkDepTree(dep, depTree, met);
  RETURN depTree
END resolve;

END vpkResolver.
