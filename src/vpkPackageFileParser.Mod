MODULE vpkPackageFileParser;
IMPORT
    vpkJsonParser,
    vpkFileManager,
    vpkHttp,
    vpkLogger,
    vpkDependencyResolver,
    vpkSettings;
CONST
    MAXARRAYNUMBER = 1000;
PROCEDURE install*;
VAR
    jsonData: ARRAY MAXARRAYNUMBER OF CHAR;
    success: BOOLEAN;
BEGIN
    vpkLogger.Log("Starting install process");
    success := vpkFileManager.fileToString(vpkSettings.packageFileName, jsonData);
    
    IF ~success THEN vpkLogger.Log("Some ERROR occured while reading VERSIONFILE") END;
    ASSERT(success);
    
    vpkLogger.Log("Starting resolving dependencies");

    vpkDependencyResolver.ResolveVersionFiles(jsonData);
    vpkDependencyResolver.ResolvePackages();
    vpkLogger.Log("======================");
    vpkLogger.Log("======================");
    vpkLogger.Log("Installation complete");
    vpkLogger.Log("Thanks for using OPIUM!");
END install;

BEGIN

END vpkPackageFileParser.
