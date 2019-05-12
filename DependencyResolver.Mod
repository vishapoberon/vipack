MODULE DependencyResolver;
IMPORT JsonParser, Settings, PackageResolver, Strings, Logger;

CONST ArrayMaxNumber = 30;

VAR
    moduleNames: ARRAY ArrayMaxNumber OF JsonParser.TString; 
    moduleJson: ARRAY ArrayMaxNumber OF JsonParser.TString; 
    moduleVersions: ARRAY ArrayMaxNumber OF JsonParser.TString;

    j : LONGINT;

PROCEDURE ResolveVersionFiles *(jsonString: ARRAY OF CHAR);
VAR
    jsonRecord, dependencies: JsonParser.JsonTypePointer;
    keyFound: BOOLEAN;
    packageName, version, filePath: ARRAY 32 OF CHAR;
    returnedJSON: JsonParser.TString;
    keys: ARRAY ArrayMaxNumber OF JsonParser.TString;
    i, k : LONGINT;
BEGIN
    jsonRecord := JsonParser.Create(jsonString);
    keyFound := jsonRecord.GetTerminal(jsonRecord, "Package", packageName);
    IF keyFound THEN
        Logger.Log("Parsing package by name");
        Logger.Log(packageName);
        Logger.Log("------------------------");
    ELSE Logger.Log("Value for the Key is not found"); RETURN; END;
    
    dependencies := jsonRecord.GetNonTerminal(jsonRecord, "Dependencies");

    IF dependencies = NIL THEN
        Logger.Log("Parsing package by name");
        Logger.Log(packageName);
        Logger.Log("Error");
        Logger.Log("No dependency");
        Logger.Log("------------------------");
    END;
    
    dependencies.GetTerminalKeys(dependencies, keys);    

    FOR i := 0 TO dependencies.TerminalNumber - 1 DO (* TODO: rewrite this logic to work with key count *)
        keyFound := dependencies.GetTerminal(dependencies, keys[i], version);
        
        IF ~keyFound THEN Logger.Log('ERROR while searching key'); Logger.Log(keys[i]); END;
        ASSERT(keyFound);

        COPY("", filePath);
        Strings.Append("/", filePath);
        Strings.Append(keys[i], filePath);
        Strings.Append("/", filePath);
        Strings.Append(version, filePath);
        Strings.Append("/", filePath);
        Strings.Append(Settings.packageFileName, filePath);
        
        JsonParser.Empty(returnedJSON);
        
        PackageResolver.ResolveFile(
            Settings.host,
            Settings.port,
            filePath,
            keys[i],
            version,
            Settings.packageFileName,
            returnedJSON
        );

        keyFound := FALSE;
        IF j >= LEN(moduleNames) THEN 
            Logger.Log("Out of range in ResolveVersionFiles function in ...");
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
    i, j: LONGINT;
    keyFound: BOOLEAN;
    jsonRecord, filesRecord: JsonParser.JsonTypePointer;
    values: ARRAY ArrayMaxNumber OF JsonParser.TString;
    host, port, path, packageName, version: JsonParser.TString;
BEGIN
    FOR i := 0 TO j - 1 DO
        IF ~Strings.Match(moduleNames[i], "") THEN
            jsonRecord := JsonParser.Create(moduleJson[i]);
            filesRecord := jsonRecord.GetNonTerminal(jsonRecord, "Files");
            
            IF filesRecord = NIL THEN 
                Logger.Log("Error: no files section found");
            END;
            
            ASSERT(filesRecord # NIL);
            keyFound := jsonRecord.GetTerminal(jsonRecord, "Remote", host);
            keyFound := jsonRecord.GetTerminal(jsonRecord, "Port", port);
            keyFound := jsonRecord.GetTerminal(jsonRecord, "Path", path);
            keyFound := jsonRecord.GetTerminal(jsonRecord, "Package", packageName);
            keyFound := jsonRecord.GetTerminal(jsonRecord, "Version", version);
            filesRecord.GetTerminalValues(filesRecord, values);
            PackageResolver.Resolve(host, port, path, packageName, version, values);
        END;
    END;
END ResolvePackages;

END DependencyResolver.