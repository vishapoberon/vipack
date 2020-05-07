MODULE vpkDependencyResolver;
IMPORT vpkJsonParser, vpkSettings, vpkPackageResolver, Strings, vpkLogger;

CONST ArrayMaxNumber = 30;

VAR
    moduleNames: ARRAY ArrayMaxNumber OF vpkJsonParser.TString; 
    moduleJson: ARRAY ArrayMaxNumber OF vpkJsonParser.TString; 
    moduleVersions: ARRAY ArrayMaxNumber OF vpkJsonParser.TString;

    j : LONGINT;

PROCEDURE ResolveVersionFiles *(jsonString: ARRAY OF CHAR);
VAR
    jsonRecord, dependencies: vpkJsonParser.JsonTypePointer;
    keyFound: BOOLEAN;
    packageName, version, filePath: ARRAY 32 OF CHAR;
    returnedJSON: vpkJsonParser.TString;
    keys: ARRAY ArrayMaxNumber OF vpkJsonParser.TString;
    i, k : LONGINT;
BEGIN
    jsonRecord := vpkJsonParser.Create(jsonString);
    keyFound := jsonRecord.GetTerminal(jsonRecord, "Package", packageName);
    IF keyFound THEN
        vpkLogger.Log("Parsing package by name");
        vpkLogger.Log(packageName);
        vpkLogger.Log("------------------------");
    ELSE vpkLogger.Log("Value for the Key is not found"); RETURN; END;
    
    dependencies := jsonRecord.GetNonTerminal(jsonRecord, "Dependencies");

    IF dependencies = NIL THEN
        vpkLogger.Log("Parsing package by name");
        vpkLogger.Log(packageName);
        vpkLogger.Log("Error");
        vpkLogger.Log("No dependency");
        vpkLogger.Log("------------------------");
    END;
    
    dependencies.GetTerminalKeys(dependencies, keys);    

    FOR i := 0 TO dependencies.TerminalNumber - 1 DO (* TODO: rewrite with working getter everywhere*)
        keyFound := dependencies.GetTerminal(dependencies, keys[i], version);
        
        IF ~keyFound THEN vpkLogger.Log('ERROR while searching key'); vpkLogger.Log(keys[i]); END;
        ASSERT(keyFound);

        COPY("", filePath);
        Strings.Append("/", filePath);
        Strings.Append(keys[i], filePath);
        Strings.Append("/", filePath);
        Strings.Append(version, filePath);
        Strings.Append("/", filePath);
        Strings.Append(vpkSettings.packageFileName, filePath);
        
        vpkJsonParser.Empty(returnedJSON);
        
        vpkPackageResolver.ResolveFile(
            vpkSettings.host,
            vpkSettings.port,
            filePath,
            keys[i],
            vpkSettings.packageFileName,
            returnedJSON
        );

        keyFound := FALSE;
        IF j >= LEN(moduleNames) THEN 
            vpkLogger.Log("Out of range in ResolveVersionFiles function in ...");
        END;
        ASSERT(j < LEN(moduleNames));
        
        FOR k := 0 TO j - 1 DO
            IF Strings.Match(moduleNames[k], keys[i]) THEN
                keyFound := TRUE;
            END;
        END;
        

        IF ~keyFound THEN 
            COPY(keys[i], moduleNames[j]);
            COPY(version, moduleVersions[j]);
            COPY(returnedJSON, moduleJson[j]);
            INC(j);
            ResolveVersionFiles(returnedJSON);
        END;
    END;
END ResolveVersionFiles;

PROCEDURE ResolvePackages*();
VAR
    i: LONGINT;
    keyFound: BOOLEAN;
    jsonRecord, filesRecord: vpkJsonParser.JsonTypePointer;
    values: ARRAY 10 OF vpkJsonParser.TString;
    host, port, path, packageName, version: ARRAY 50 OF CHAR;
BEGIN
    FOR i := 0 TO j - 1 DO
        jsonRecord := vpkJsonParser.Create(moduleJson[i]);
        filesRecord := jsonRecord.GetNonTerminal(jsonRecord, "Files");
        
        IF filesRecord = NIL THEN 
            vpkLogger.Log("Error: no files section found");
        END;
        
        ASSERT(filesRecord # NIL);
        keyFound := jsonRecord.GetTerminal(jsonRecord, "Remote", host);
        keyFound := jsonRecord.GetTerminal(jsonRecord, "Port", port);
        keyFound := jsonRecord.GetTerminal(jsonRecord, "Path", path);
        keyFound := jsonRecord.GetTerminal(jsonRecord, "Package", packageName);
        keyFound := jsonRecord.GetTerminal(jsonRecord, "Version", version);
        vpkPackageResolver.Resolve(host, port, path, packageName, version, filesRecord.TerminalValues); (* TODO: filesRecord.TerminalValues create working getter for this*)
    END;
END ResolvePackages;

END vpkDependencyResolver.
