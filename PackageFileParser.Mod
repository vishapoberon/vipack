MODULE PackageFileParser;
IMPORT
    JsonParser,
    FileManager,
    http,
    Logger;
CONST
    MAXARRAYNUMBER = 1000000;
PROCEDURE install*;
VAR
    fileData, buff, buff2: ARRAY MAXARRAYNUMBER OF CHAR;
    success: BOOLEAN;
BEGIN
    Logger.Log("Starting install process");
    success := FileManager.Read("VersionFile.json", fileData);
    
    IF ~success THEN Logger.Log("Some ERROR occured while reading VERSIONFILE") END;
    ASSERT(success);

    http.get("norayr.am", "/tmp/", "80", buff);
    http.getClean(buff, buff2);

    success := FileManager.Write("index.html", buff2);

    IF ~success THEN Logger.Log("Some ERROR occured while writing to test gile") END;
    ASSERT(success)
END install;

BEGIN

END PackageFileParser.