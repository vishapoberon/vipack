MODULE vpkInstaller;
IMPORT StringList, vpkResolver, vpkdepTree, vpkDot;

PROCEDURE install*(VAR unit: ARRAY OF CHAR);
VAR
  tree: vpkdepTree.TdepTree;
  lst: StringList.TStringList;
BEGIN
  tree := vpkResolver.resolve(unit);
  lst  := vpkDot.tree2dot(tree);

END install;


END vpkInstaller.
