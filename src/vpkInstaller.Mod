MODULE vpkInstaller;
IMPORT Out, StringList, vpkResolver, vpkdepTree, vpkDot, vpkEnv, vpkJsonDepRetriever, vpkSyncer, Platform;

PROCEDURE resolve*(VAR unit: ARRAY OF CHAR): vpkdepTree.TdepTree;
VAR
  tree: vpkdepTree.TdepTree;
  lst: StringList.TStringList;
  dep:  vpkdepTree.Tdep;
  i : LONGINT;
  graphName : ARRAY 32 OF CHAR;
BEGIN
  vpkEnv.getGraphName(graphName);
  Out.Ln; Out.String("resolving dependencies..."); Out.Ln;
  tree := vpkResolver.resolve(unit, vpkJsonDepRetriever.getDeps);
  Out.String(" done! (:"); Out.Ln; Out.Ln;
  lst  := vpkDot.tree2dot(tree);
  Out.String("dependency graph:"); Out.Ln; 
  Out.String("-----------------"); Out.Ln;
  StringList.DumpOut(lst);
  lst.Dump(lst, graphName);
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
  UNTIL i = depTree.Count;
END fetch;

PROCEDURE build*(VAR package, prefix, tree: ARRAY OF CHAR);
VAR
  depTree: vpkdepTree.TdepTree;
      dep: vpkdepTree.Tdep;
     i, j: LONGINT;
      URI: ARRAY 128 OF CHAR;
      typ: ARRAY 16  OF CHAR;
      keys, values: StringList.TStringList;
      k, v: StringList.pstring;
      b: BOOLEAN;
      builddir, cmd, srcPath: StringList.pstring;
      res: INTEGER;
BEGIN
  builddir := vpkEnv.mkBldDir(prefix);
  depTree := resolve(package);
  i := 0;
  REPEAT
    dep := vpkdepTree.Get(depTree, i);
    vpkJsonDepRetriever.getURIandType(dep, URI, typ);
    vpkSyncer.fetch(dep.name^, URI, typ, prefix);
    b := FALSE;
    b := vpkJsonDepRetriever.getBuildInfo(dep, keys, values);
    IF b THEN
      j := 0;
      REPEAT
        k := keys.GetString(keys, j);
        v := values.GetString(values, j);
        res := Platform.Chdir(builddir^);
        IF res # 0 THEN
          Out.String("failed to change directory to "); Out.String(builddir^); Out.Ln; Out.String("this should never happen."); Out.Ln; HALT(66);
        END;
        srcPath := vpkEnv.getSrcRelPath(dep.name^, v^);
        Out.String(srcPath^); Out.Ln;
        cmd := vpkEnv.mkCmd(k^, srcPath^);
        Out.String(cmd^);
        res := Platform.System(cmd^);
        IF res # 0 THEN Out.String("failed to run build command"); Out.Ln END;
        INC(j)
      UNTIL j = keys.Count - 1;
    ELSE
      Out.String("no build info found for the package: "); Out.String(dep.name^); Out.Ln;
    END;
    INC(i);
  UNTIL i = depTree.Count;
END build;
END vpkInstaller.
