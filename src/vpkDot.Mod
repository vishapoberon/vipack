MODULE vpkDot;
IMPORT Out, Strings, vpkdepTree, StringList;

CONST
  first = "digraph dependencies {";
  last  = "}";
  arrow = " -> ";
  tab   = "  ";

PROCEDURE tree2dot*(VAR tree: vpkdepTree.TdepTree): StringList.TStringList;
VAR
  dep : vpkdepTree.Tdep;
  i, j : LONGINT;
  lst : StringList.TStringList;
  line: ARRAY 64 OF CHAR;
BEGIN
  lst := StringList.Create();
  line:= first;
  lst.AppendString(lst, line);
  i := 0;
  REPEAT
              (*  Out.String("entered repeat"); Out.Ln;*)
    dep := tree.Get(tree, i);
    IF dep # NIL THEN
                       (*    Out.String("dep # nil"); Out.Ln;*)
      IF dep.deps # NIL THEN
                          (* Out.String("dep.deps # nil"); Out.Ln;*)
        j := 0;
        REPEAT
                      (*  Out.String("other repeat");Out.Ln;*)
          IF dep.deps[j]^.name # NIL THEN
            COPY("", line);
            Strings.Append(tab, line);
            Strings.Append(dep.name^, line);
            Strings.Append(arrow, line);
            Strings.Append(dep.deps[j]^.name^, line);
            lst.AppendString(lst, line);
                           (* Out.String("appends over"); Out.Ln;*)
          END;
          INC(j);
                 (*Out.String("j="); Out.Int(j,0); Out.Ln;
                 Out.String("len dep.deps"); Out.Int(LEN(dep.deps^), 0); Out.Ln;*)
        UNTIL j = (LEN(dep.deps^));
      END
    END;
    INC(i)
  UNTIL i = tree.Count ;
  line := last;
  lst.AppendString(lst, line);
  RETURN lst;
END tree2dot;

END vpkDot.
