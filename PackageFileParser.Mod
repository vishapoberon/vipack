MODULE PackageFileParser;
IMPORT
    JsonParser,
    FileManager,
    http,
    Logger,
    DependencyResolver,
    Settings;
CONST
    MAXARRAYNUMBER = 1000000;
PROCEDURE install*;
VAR
    jsonData: ARRAY MAXARRAYNUMBER OF CHAR;
    success: BOOLEAN;
BEGIN
    Logger.Log("Starting install process");
    success := FileManager.Read(Settings.packageFileName, jsonData);
    
    IF ~success THEN Logger.Log("Some ERROR occured while reading VERSIONFILE") END;
    ASSERT(success);

    DependencyResolver.Resolve(jsonData);
END install;

BEGIN

END PackageFileParser.