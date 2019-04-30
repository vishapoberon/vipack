MODULE PackageFileParser;
IMPORT
    JsonParser,
    FileManager,
    Logger;
CONST
    MAXARRAYNUMBER = 1000;
PROCEDURE install*;
VAR
    fileData: ARRAY MAXARRAYNUMBER OF CHAR;
    successfullyParsed: BOOLEAN;
BEGIN
    Logger.Log("Starting install process");
    successfullyParsed := FileManager.Read("VersionFile.json", fileData);
    
    IF ~successfullyParsed THEN Logger.Log("Some ERROR occured while reading VERSIONFILE") END;
    ASSERT(successfullyParsed);

    Logger.Log(fileData);
END install;

BEGIN

END PackageFileParser.