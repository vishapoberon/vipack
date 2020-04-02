MODULE vpkPackageResolver;
IMPORT vpkFileManager, vpkHttp, Strings, vpkLogger, vpkSettings, vpkJsonParser;

CONST ArrayMaxNumber = 1000;

PROCEDURE ResolveFile *(host, port, path, packageName, fileName : ARRAY OF CHAR; VAR returnValue : ARRAY OF CHAR);
VAR
    localPath: ARRAY ArrayMaxNumber OF CHAR;
    isSuccessfull: BOOLEAN;
BEGIN
    vpkLogger.Log('path');
    vpkLogger.Log(path);
    vpkHttp.get(host, port, path, returnValue);
    vpkHttp.getClean(returnValue, returnValue);
    isSuccessfull := vpkFileManager.CreateDirectory(packageName, vpkSettings.installPath);

    IF ~isSuccessfull THEN vpkLogger.Log("Something went wrong, while downloading files") END;
    ASSERT(isSuccessfull);
    vpkLogger.Log(path);

    vpkLogger.Log(packageName);
    COPY(vpkSettings.installPath, localPath);

    Strings.Append("/", localPath);
    Strings.Append(packageName, localPath);
    Strings.Append("/", localPath);
    Strings.Append(fileName, localPath);

    isSuccessfull := vpkFileManager.Write(localPath, returnValue);
    
END ResolveFile;

PROCEDURE Resolve *(host, port, path, packageName, version: ARRAY OF CHAR; files: ARRAY OF vpkJsonParser.TString);
VAR
    i : LONGINT;
    helperString: ARRAY 10000 OF CHAR;
BEGIN
    Strings.Append("/", path);
    FOR i := 0 TO LEN(files) - 1 DO
        IF ~Strings.Match(files[i], "") THEN
            vpkJsonParser.Empty(helperString);
            COPY(path, helperString);
            Strings.Append(files[i], helperString);
            
            ResolveFile(host, port, helperString, packageName, files[i], helperString);
        END;
    END;
END Resolve;

END vpkPackageResolver.
