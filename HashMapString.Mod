MODULE HashMap;
IMPORT Logger, CharacterStack, Strings, Out;
CONST
    ArrayMaxNumber = 100;
    (* Const *)
    symbolBracketStart = "{";
    symbolBracketEnd = "}";
    (* TODO: Reverse " and ' *)
    quote = "'";
    coma = ",";
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

(* 
    TODO:
        Create a good validation for comas
        Create a good validation for name repetition
*)

PROCEDURE PushDownString(
    string: ARRAY OF CHAR; 
    startCharacter: CHAR; 
    endCharacter: CHAR; 
    i: LONGINT; 
    VAR returnString: ARRAY OF CHAR): LONGINT;
VAR
    characterStack: CharacterStack.CharacterStackType;
    j , k: LONGINT;
BEGIN
    NEW(characterStack);
    j := i;
    characterStack := CharacterStack.Create();
    REPEAT
        IF (characterStack.Count > 1) & (string[j] = endCharacter) THEN 
            REPEAT UNTIL characterStack.pop(characterStack) = startCharacter;
        ELSE
            characterStack.push(characterStack, string[j]);
            INC(j);
        END;
    UNTIL characterStack.top(characterStack) = 0AX;

    FOR k := i TO j DO
        returnString[k - i] := string[k];
    END;
    
    RETURN j; (* returning next symbol of quote *)
END PushDownString;

PROCEDURE Create*(text: ARRAY OF CHAR): JsonTypePointer;
VAR
    self: JsonTypePointer; 
    i, j, terminalIterator, noneTerminalIterator: LONGINT;
    characterStack: CharacterStack.CharacterStackType;
    key, val, nonTerminalVal, string: ARRAY ArrayMaxNumber OF CHAR;
    symbol: CHAR;
    symbolStart: CHAR;
    quoteStart: BOOLEAN;
BEGIN
    NEW(self);
    NEW(self.NonTerminalValues, ArrayMaxNumber);
    self.GetTerminal := GetTerminal;

    NEW(characterStack);
    characterStack := CharacterStack.Create();
    
    i := 0;
    j := 0;
    terminalIterator := 0;
    noneTerminalIterator := 0;
    
    quoteStart := FALSE;

    REPEAT
        IF (text[i] = symbolBracketStart) & (i = 0) THEN
            INC(i);
            Logger.Log("Starting Parse Json");
        END;

        IF symbol = symbolBracketStart THEN
            Logger.Log("End Parsing Json");
        END;
        
        symbol := text[i];

        (* terminals *)
        IF symbol = quote THEN
            i := PushDownString(text, quote, quote, i, string);
        END;

        IF (Strings.Length(string) > 0) & (symbol = quote) THEN
            IF Strings.Length(key) > 0 THEN
                COPY(string, val)
            ELSE
                COPY(string, key) 
            END;
            
            COPY("", string);
        END;

        IF (Strings.Length(key) > 0) & (Strings.Length(val) > 0) THEN
            COPY(key, self.TerminalKeys[terminalIterator]);
            COPY(val, self.TerminalsValues[terminalIterator]);
            INC(terminalIterator);
                        
            COPY("", key);
            COPY("", val);
        END;
        
        (* none terminals *)        
        IF symbol = symbolBracketStart THEN
            i := PushDownString(text, symbolBracketStart, symbolBracketEnd, i, string);
        END;

        IF (Strings.Length(string) > 0) & (symbol = symbolBracketStart) THEN
            IF Strings.Length(key) > 0 THEN
                COPY(string, nonTerminalVal)
            ELSE
                COPY(string, key) 
            END;
            
            COPY("", string);
        END;

        IF (Strings.Length(text) > 0) & (Strings.Length(nonTerminalVal) > 0) THEN
       
            COPY(key, self.NonTerminalKeys[noneTerminalIterator]);
            self.NonTerminalValues[noneTerminalIterator] := Create(nonTerminalVal);

            INC(noneTerminalIterator);

            COPY("", key);
            COPY("", nonTerminalVal);
        END;
        
        INC(i);
    UNTIL i > LEN(text) - 1;

    RETURN self;
END Create;

BEGIN
    NEW(jsonRecord);
    jsonRecord := Create("{'foo': 'bar', 'test': 'test1', 'test2': {'asdasd': 'asd'}}");

    keyFound := jsonRecord.GetTerminal(jsonRecord, "'test'", testValue);

    IF keyFound THEN
        Logger.Log('found KEY');
        Logger.Log(testValue);
    ELSE Logger.Log('Value for the Key is not found') END;

END HashMap.