MODULE vpkInstaller;
IMPORT StringList, vpkResolver, vpkdepTree, vpkDot, vpkSettings;

PROCEDURE install*(VAR unit: ARRAY OF CHAR);
VAR
  tree: vpkdepTree.TdepTree;
  lst: StringList.TStringList;
BEGIN
  tree := vpkResolver.resolve(unit);
  lst  := vpkDot.tree2dot(tree);
  lst.Dump(lst, vpkSettings.graphName);
END install;


END vpkInstaller.
