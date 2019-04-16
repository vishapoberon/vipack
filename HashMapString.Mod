MODULE HashMap;
IMPORT Logger, CharacterStack, Strings;
CONST
    ArrayMaxNumber = 5000;
TYPE
    TString = ARRAY ArrayMaxNumber OF CHAR;
    
    JsonTypePointer* = POINTER TO JsonType;


    
    JsonType* = RECORD
        GetTerminal* : PROCEDURE(self : JsonTypePointer; string : ARRAY OF CHAR; VAR returnValue : ARRAY OF CHAR);
        GetNonTerminal* : PROCEDURE(self : JsonTypePointer; key : ARRAY OF CHAR): JsonTypePointer;
        HasKey* : PROCEDURE(self : JsonTypePointer; key : ARRAY OF CHAR): BOOLEAN;
        TypeOfTheKey* : PROCEDURE(self : JsonTypePointer; key : ARRAY OF CHAR; VAR returnValue : ARRAY OF CHAR);

        TerminalsValues : ARRAY ArrayMaxNumber OF TString;
        TerminalKeys : ARRAY ArrayMaxNumber OF TString;

        NonTerminalValues : POINTER TO ARRAY OF JsonTypePointer;
        NonTerminalKeys : ARRAY ArrayMaxNumber OF TString;
    END;
    
VAR
    jsonRecord :JsonTypePointer;


PROCEDURE Create*(text: ARRAY OF CHAR): JsonTypePointer;
VAR
    jsonRecord: JsonTypePointer; 
    everethingIsOK: BOOLEAN;
    i,j: INTEGER;
    characterStack: CharacterStack.CharacterStackType;
    key, val: ARRAY ArrayMaxNumber OF CHAR;
    symbol: CHAR;
    symbolBracketStart, symbolBracketEnd, symbolStart: CHAR;
BEGIN
    NEW(jsonRecord);
    NEW(characterStack);
    characterStack := CharacterStack.Create();

    symbolBracketStart := "{";
    symbolBracketEnd := "}";
    
    i := 0;
    j := 0;

    REPEAT
        symbol := text[i];
        INC(i);

        IF symbol = symbolBracketStart THEN
            Logger.Log("Starting Parse Json");
        END;

        IF symbol = symbolBracketStart THEN
            Logger.Log("End Parsing Json");
        END;
    UNTIL text[i] = 0AX;

    RETURN jsonRecord;
END Create;

BEGIN
    NEW(jsonRecord);
    jsonRecord := Create('{"asdasd": "test"}');
END HashMap.