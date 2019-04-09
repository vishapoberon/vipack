MODULE HashMap;
IMPORT Logger;
TYPE
    JsonTypePointer* = POINTER TO JsonType;
    JsonType* = RECORD
        GetTerminal* : PROCEDURE(self : JsonTypePointer, string : STRING): STRING;
        GetNonTerminal* : PROCEDURE(self : JsonTypePointer, key : STRING): JsonTypePointer;
        HasKey* : PROCEDURE(self : JsonTypePointer, key : STRING): BOOLEAN;
        TypeOfTheKey* : PROCEDURE(self : JsonTypePointer, key : STRING): STRING;
        Create* : PROCEDURE(self : JsonTypePointer, key : STRING): BOOLEAN;

        TerminalsValues : ARRAY OF STRING;
        TerminalKeys : ARRAY OF STRING;

        NonTerminalValues : ARRAY OF JsonTypePointer;
        NonTerminalKeys : ARRAY OF STRING;
    END;
    
    PROCEDURE makeACopy(VAR STR1, STR2: ARRAY OF CHAR):
    BEGIN
    (* TODO *)
    END;

    PROCEDURE Create*(VAR self : JsonTypePointer, text: ARRAY OF CHAR): BOOLEAN;
    VAR
        everethingIsOK: BOOLEAN;
        i,j: INTEGER;
        stack, key, val: ARRAY OF CHAR;
        symbolBracketStart, symbolBracketEnd, symbolStart: CHAR;
    BEGIN
        symbolBracketStart := "{";
        symbolBracketEnd := "}";
        symbol := "\"";
        j := 0;

        i := 0;
        REPEAT
        
            symbol := text[i];
            INC(i);

            IF symbol = symbolBracketStart THEN
                Logger.out("Starting Parse Json")
            END;

            IF symbol = symbolBracketStart THEN
                Logger.out("End Parsing Json")
            END;

            makeACopy(key, self.TerminalKeys[j]);
            makeACopy(value, self.TerminalsValues[j]);

        UNTIL i = LEN(text);

        RETURN everethingIsOK;
    END;

END;
END HashMap.