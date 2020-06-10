MODULE vpkInstaller;
IMPORT Out, StringList, vpkResolver, vpkdepTree, vpkDot, vpkSettings;

PROCEDURE install*(VAR unit: ARRAY OF CHAR);
VAR
  tree: vpkdepTree.TdepTree;
  lst: StringList.TStringList;
  dep:  vpkdepTree.Tdep;
  i : LONGINT;
BEGIN
  Out.String("resolving dependencies...");
  tree := vpkResolver.resolve(unit);
  Out.String(" done!"); Out.Ln;
  lst  := vpkDot.tree2dot(tree);
  Out.String("dependency graph:"); Out.Ln; 
  Out.String("-----------------"); Out.Ln;
  StringList.DumpOut(lst);
  lst.Dump(lst, vpkSettings.graphName);
  Out.String("-----------------"); Out.Ln;
  Out.String("(use 'dot -Tpng deps.dot > deps.png' to get the graph image)"); Out.Ln; Out.Ln;
  Out.String("dependencies will be installed in the following order:"); Out.Ln;
  i := 0;
  REPEAT
    dep := vpkdepTree.Get(tree, i);
    Out.String(dep.name^); Out.Ln;
    INC(i)
  UNTIL i = tree.Count;

END install;


END vpkInstaller.
