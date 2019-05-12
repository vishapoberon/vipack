MODULE PackageResolver;
IMPORT FileManager, http, Strings, Logger, Settings, JsonParser;

CONST ArrayMaxNumber = 1000;

PROCEDURE ResolveFile *(host, port, path, packageName, fileName : ARRAY OF CHAR; VAR returnValue : ARRAY OF CHAR);
VAR
    localPath: ARRAY ArrayMaxNumber OF CHAR;
    isSuccessfull: BOOLEAN;
BEGIN
    Logger.Log('path');
    Logger.Log(path);
    http.get(host, port, path, returnValue);
    http.getClean(returnValue, returnValue);
    isSuccessfull := FileManager.CreateDirectory(packageName, Settings.installPath);

    IF ~isSuccessfull THEN Logger.Log("Something went wrong, while downloading files") END;
    ASSERT(isSuccessfull);
    Logger.Log(path);

    Logger.Log(packageName);
    COPY(Settings.installPath, localPath);

    Strings.Append("/", localPath);
    Strings.Append(packageName, localPath);
    Strings.Append("/", localPath);
    Strings.Append(fileName, localPath);

    isSuccessfull := FileManager.Write(localPath, returnValue);
    
END ResolveFile;

PROCEDURE Resolve *(host, port, path, packageName, version: ARRAY OF CHAR; files: ARRAY OF JsonParser.TString);
VAR
    i : LONGINT;
    helperString: ARRAY 10000 OF CHAR;
BEGIN
    Strings.Append("/", path);
    FOR i := 0 TO LEN(files) - 1 DO
        IF ~Strings.Match(files[i], "") THEN
            JsonParser.Empty(helperString);
            COPY(path, helperString);
            Strings.Append(files[i], helperString);
            
            ResolveFile(host, port, helperString, packageName, files[i], helperString);
        END;
    END;
END Resolve;

END PackageResolver.