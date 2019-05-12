MODULE PackageFileParser;
IMPORT
    JsonParser,
    FileManager,
    http,
    Logger,
    DependencyResolver,
    Settings;
CONST
    MAXARRAYNUMBER = 1000;
PROCEDURE install*;
VAR
    jsonData: ARRAY MAXARRAYNUMBER OF CHAR;
    success: BOOLEAN;
BEGIN
    Logger.Log("Starting install process");
    success := FileManager.Read(Settings.packageFileName, jsonData);
    
    IF ~success THEN Logger.Log("Some ERROR occured while reading VERSIONFILE") END;
    ASSERT(success);
    
    Logger.Log("Starting resolving dependencies");

    DependencyResolver.ResolveVersionFiles(jsonData);
    DependencyResolver.ResolvePackages();
    Logger.Log("======================");
    Logger.Log("======================");
    Logger.Log("Installation complete");
    Logger.Log("Thanks for using OPIUM!");
END install;

BEGIN

END PackageFileParser.