MODULE PackageFileParser;
IMPORT
    JsonParser,
    FileManager,
    http,
    Logger,
    DependencyResolver,
    Settings;
CONST
    MAXARRAYNUMBER = 10000;
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
    Logger.Log(jsonData);

    DependencyResolver.Resolve(jsonData);
END install;

BEGIN

END PackageFileParser.