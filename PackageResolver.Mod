MODULE PackageResolver;
IMPORT FileManager, http, Strings, Logger, Settings, JsonParser;

CONST ArrayMaxNumber = 1000;

PROCEDURE ResolveFile *(host, port, path, packageName, version, fileName : ARRAY OF CHAR; VAR returnValue : ARRAY OF CHAR);
VAR
    localPath: ARRAY ArrayMaxNumber OF CHAR;
    isSuccessfull: BOOLEAN;
BEGIN
    http.get(host, port, path, returnValue);
    http.getClean(returnValue, returnValue);
    isSuccessfull := FileManager.CreateDirectory(packageName, Settings.installPath);
    
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
    returnValue: JsonParser.TString;
BEGIN
    FOR i := 0 TO LEN(files) - 1 DO
        IF ~Strings.Match(files[i], "") THEN
            ResolveFile(host, port, path, packageName, version, files[i], returnValue);
        END;
    END;
END Resolve;

END PackageResolver.