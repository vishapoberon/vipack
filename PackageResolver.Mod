MODULE PackageResolver;
IMPORT FileManager, http, Strings, Logger, Settings;

CONST ArrayMaxNumber = 10000;

PROCEDURE *Resolve(remoteURL, port, packageName, version : ARRAY OF CHAR);
BEGIN

END Resolve;

PROCEDURE ResolveFile *(host, port, packageName, version, fileName : ARRAY OF CHAR; VAR returnValue : ARRAY OF CHAR);
VAR
    filePath, localPath: ARRAY ArrayMaxNumber OF CHAR;
    isSuccessfull: BOOLEAN;
BEGIN
    filePath := "";
    Strings.Append("/", filePath);
    Strings.Append(packageName, filePath);
    Strings.Append("/", filePath);
    Strings.Append(version, filePath);
    Strings.Append("/", filePath);
    Strings.Append(fileName, filePath);

    http.get(host, port, filePath, returnValue);
    http.getClean(returnValue, returnValue);
    isSuccessfull := FileManager.CreateDirectory(packageName, Settings.installPath);
    
    COPY(Settings.installPath, localPath);
    Strings.Append("/", localPath);
    Strings.Append(packageName, localPath);
    Strings.Append("/", localPath);
    Strings.Append(fileName, localPath);

    isSuccessfull := FileManager.Write(localPath, returnValue);
    
END ResolveFile;


END PackageResolver.