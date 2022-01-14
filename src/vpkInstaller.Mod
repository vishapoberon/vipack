MODULE vpkInstaller;
IMPORT Out, StringList, vpkResolver, vpkdepTree, vpkDot, vpkSettings, vpkJsonDepRetriever, vpkSyncer;

PROCEDURE resolve*(VAR unit: ARRAY OF CHAR): vpkdepTree.TdepTree;
VAR
  tree: vpkdepTree.TdepTree;
  lst: StringList.TStringList;
  dep:  vpkdepTree.Tdep;
  i : LONGINT;
BEGIN
  Out.Ln; Out.String("resolving dependencies..."); Out.Ln;
  tree := vpkResolver.resolve(unit, vpkJsonDepRetriever.getDeps);
  Out.String(" done! (:"); Out.Ln; Out.Ln;
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
  RETURN tree
END resolve;

PROCEDURE fetch*(VAR package, prefix, pkgTree: ARRAY OF CHAR);
VAR
  depTree: vpkdepTree.TdepTree;
      dep: vpkdepTree.Tdep;
        i: LONGINT;
      URI: ARRAY 128 OF CHAR;
      typ: ARRAY 16 OF CHAR;
BEGIN
  depTree := resolve(package);
  i := 0;
  REPEAT
    dep := vpkdepTree.Get(depTree, i);
    vpkJsonDepRetriever.getURIandType(dep, URI, typ); 
    vpkSyncer.fetch(dep.name^, URI, typ, prefix);
    INC(i)
  UNTIL i= depTree.Count;
END fetch;

PROCEDURE build*(VAR package, prefix, tree: ARRAY OF CHAR);

BEGIN

END build;
END vpkInstaller.
