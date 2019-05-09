MODULE DependencyResolver;
IMPORT JsonParser, Settings, PackageResolver, Strings, Logger;

CONST ArrayMaxNumber = 10000;

VAR
    moduleNames: ARRAY ArrayMaxNumber OF JsonParser.TString; 
    moduleJson: ARRAY ArrayMaxNumber OF JsonParser.TString; 
    moduleVersions: ARRAY ArrayMaxNumber OF JsonParser.TString;
    j : LONGINT;

PROCEDURE Resolve *(jsonString: ARRAY OF CHAR);
VAR
    jsonRecord, dependencies: JsonParser.JsonTypePointer;
    keyFound: BOOLEAN;
    packageName, version, returnedJSON: ARRAY ArrayMaxNumber OF CHAR;
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
    
    dependencies.GetTerminalKeys(dependencies, keys);

    FOR i := 0 TO LEN(keys) - 1 DO
        keyFound := dependencies.GetTerminal(dependencies, keys[i], version);
        
        IF ~keyFound THEN Logger.Log('ERROR while seatching key'); Logger.Log(keys[i]); END;
        ASSERT(keyFound);

        PackageResolver.ResolveFile(
            Settings.host,
            Settings.port,
            keys[i],
            version,
            Settings.packageFileName,
            returnedJSON
        );
        
        keyFound := FALSE;
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
            Resolve(returnedJSON);
        END;
    END;

END Resolve;

END DependencyResolver.