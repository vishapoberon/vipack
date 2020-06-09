MODULE vpkInstaller;
IMPORT StringList, vpkResolver;

PROCEDURE install*(VAR unit: ARRAY OF CHAR);
BEGIN
  vpkResolver.resolve(unit);

END install;


END vpkInstaller.
