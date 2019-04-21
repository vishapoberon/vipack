MODULE HashMap;
IMPORT Logger, CharacterStack, Strings;
CONST
    ArrayMaxNumber = 5000;
    symbolBracketStart = "{";
    symbolBracketEnd = "}";
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
    i,j: INTEGER;
    characterStack: CharacterStack.CharacterStackType;
    key, val: ARRAY ArrayMaxNumber OF CHAR;
    symbol: CHAR;
    symbolStart: CHAR;
BEGIN
    NEW(jsonRecord);
    NEW(characterStack);
    characterStack := CharacterStack.Create();
    
    i := 0;
    j := 0;

    REPEAT
        symbol := text[i];
        IF symbol = symbolBracketStart THEN
            Logger.Log("Starting Parse Json");
        END;

        IF symbol = symbolBracketStart THEN
            Logger.Log("End Parsing Json");
        END;
        INC(i);
    UNTIL i > LEN(text) - 1;
    (* UNTIL text[i] = 0AX; TODO: Ask Norayr *)
    
    RETURN jsonRecord;
END Create;

BEGIN
    NEW(jsonRecord);
    jsonRecord := Create('{"asdasd": "test"}');
END HashMap.