MODULE HashMap;
IMPORT Logger, CharacterStack, Strings, Out;
CONST
    ArrayMaxNumber = 5000;
TYPE
    TString = ARRAY ArrayMaxNumber OF CHAR;
    
    JsonTypePointer* = POINTER TO JsonType;

    JsonType* = RECORD
        GetTerminal* : PROCEDURE(self : JsonTypePointer; string : ARRAY OF CHAR; VAR returnValue : ARRAY OF CHAR): BOOLEAN;
        GetNonTerminal* : PROCEDURE(self : JsonTypePointer; key : ARRAY OF CHAR): JsonTypePointer;
        HasKey* : PROCEDURE(self : JsonTypePointer; key : ARRAY OF CHAR): BOOLEAN;
        TypeOfTheKey* : PROCEDURE(self : JsonTypePointer; key : ARRAY OF CHAR; VAR returnValue : ARRAY OF CHAR);

        TerminalKeys : ARRAY ArrayMaxNumber OF TString;
        TerminalsValues : ARRAY ArrayMaxNumber OF TString;

        NonTerminalKeys : ARRAY ArrayMaxNumber OF TString;
        NonTerminalValues : POINTER TO ARRAY OF JsonTypePointer;
    END;
    
VAR
    jsonRecord: JsonTypePointer;
    testValue: ARRAY ArrayMaxNumber OF CHAR;
    keyFound: BOOLEAN;
    
PROCEDURE GetTerminal *(self: JsonTypePointer; key: ARRAY OF CHAR; VAR returnValue: ARRAY OF CHAR): BOOLEAN;
VAR
    i: LONGINT;
BEGIN
    FOR i := 0 TO LEN(self.TerminalKeys) - 1 DO
        IF Strings.Match(key, self.TerminalKeys[i]) THEN COPY(self.TerminalsValues[i], returnValue); RETURN TRUE END;
    END;
    RETURN FALSE;
END GetTerminal;

PROCEDURE Create*(text: ARRAY OF CHAR): JsonTypePointer;
VAR
    self: JsonTypePointer; 
    i,j,k,s: LONGINT;
    characterStack: CharacterStack.CharacterStackType;
    key, val, string: ARRAY ArrayMaxNumber OF CHAR;
    symbol: CHAR;
    symbolStart: CHAR;
    quoteStart: BOOLEAN;
    symbolBracketStart, symbolBracketEnd, quote: CHAR;
BEGIN
    (* Const *)
    symbolBracketStart := "{";
    symbolBracketEnd := "}";
    (* TODO: Reverse " and ' *)
    quote := "'";

    NEW(self);
    NEW(self.NonTerminalValues, ArrayMaxNumber);
    self.GetTerminal := GetTerminal;

    NEW(characterStack);
    characterStack := CharacterStack.Create();
    
    i := 0;
    j := 0;
    k := 0;
    
    quoteStart := FALSE;

    REPEAT
        symbol := text[i];
        IF symbol = symbolBracketStart THEN
            Logger.Log("Starting Parse Json");
        END;

        IF symbol = symbolBracketStart THEN
            Logger.Log("End Parsing Json");
        END;
        
        IF ~quoteStart & (symbol = quote) THEN quoteStart := TRUE
        ELSIF quoteStart & (symbol # quote) THEN characterStack.push(characterStack, symbol)
        ELSIF quoteStart & (symbol = quote) THEN
            j := characterStack.Count;
            WHILE characterStack.top(characterStack) # 0AX DO
                DEC(j);
                string[j] := characterStack.pop(characterStack);
            END;
            quoteStart := FALSE;
        END;

        IF (Strings.Length(string) > 0) & ~quoteStart THEN
            
            IF Strings.Length(key) > 0 THEN
                COPY(string, val)
            ELSE
                COPY(string, key) 
            END;
            
            COPY("", string);
        END;

        IF (Strings.Length(key) > 0) & (Strings.Length(val) > 0) THEN
            COPY(key, self.TerminalKeys[k]);
            COPY(val, self.TerminalsValues[k]);
            INC(k);
            COPY("", key);
            COPY("", val);
        END;

        INC(i);
    UNTIL i > LEN(text) - 1;

    RETURN self;
END Create;

BEGIN
    NEW(jsonRecord);
    jsonRecord := Create("{'foo': 'bar', 'test': 'test1'}");
    keyFound := jsonRecord.GetTerminal(jsonRecord, "test", testValue);

    IF keyFound THEN
        Logger.Log('found KEY');
        Logger.Log(testValue);
    ELSE Logger.Log('Value for the Key is not found') END;

END HashMap.