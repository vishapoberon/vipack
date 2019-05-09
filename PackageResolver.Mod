MODULE PackageResolver;
IMPORT FileManager, http, Strings;

CONST ArrayMaxNumber = 10000;

PROCEDURE *Resolve(remoteURL, port, packageName, version : ARRAY OF CHAR);
BEGIN

END Resolve;

PROCEDURE ResolveFile *(host, port, packageName, version, fileName : ARRAY OF CHAR; VAR returnValue : ARRAY OF CHAR);
VAR
    filePath: ARRAY ArrayMaxNumber OF CHAR;
BEGIN
    filePath := "";
    Strings.Append("/", filePath);
    Strings.Append(packageName, filePath);
    Strings.Append("/", filePath);
    Strings.Append(version, filePath);
    Strings.Append("/", filePath);
    Strings.Append(fileName, filePath);

    http.get(host, port, filePath, returnValue);
    
    (* TODO: introduce write to file functionality *)
    (* FileManager.CreateDirectory(packageName); *)
    (* FileManager.Write(packageName + fileName, returnValue); *)
    
END ResolveFile;


END PackageResolver.