MODULE vpkDot;
IMPORT Strings, vpkdepTree, StringList;

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
    dep := tree.Get(tree, i);
    IF dep # NIL THEN
      IF dep.deps # NIL THEN
        j := 0;
        REPEAT
          IF dep.deps[j]^.name # NIL THEN
            COPY("", line);
            Strings.Append(tab, line);
            Strings.Append(dep.name^, line);
            Strings.Append(arrow, line);
            Strings.Append(dep.deps[j]^.name^, line);
            lst.AppendString(lst, line);
          END;
          INC(j)
        UNTIL j = (LEN(dep.deps^) -1 );
      END
    END;
    INC(i)
  UNTIL i = tree.Count ;
  line := last;
  lst.AppendString(lst, line);
  RETURN lst;
END tree2dot;

END vpkDot.
