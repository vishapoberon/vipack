MODULE CharaterStack;
IMPORT List, Out, Sys;

TYPE 
    integer* = Sys.integer;

    TChar* = POINTER TO TCharDesc;
    
    TCharDesc = RECORD (List.NodeDesc)
        char* : CHAR
    END;

    string = Sys.string;

    CharacterStackType = POINTER TO CharacterStackTypeDesc;
    
    CharacterStackTypeDesc = RECORD (List.TListDesc)
        pop: PROCEDURE(self: CharacterStackType): CHAR;
        push: PROCEDURE(self: CharacterStackType; char: CHAR);
        top: PROCEDURE(self: CharacterStackType) : CHAR;
    END;

PROCEDURE pop(self: CharacterStackType): CHAR;
VAR
    ch: TChar;
BEGIN
    NEW(ch);
    ch := self.Get(self, self.Count);
    self.Delete(self, self.Count);
    RETURN ch.char;
END pop;

PROCEDURE push(self: CharacterStackType; char: CHAR);
VAR
    int: integer;
    ch: TChar;
BEGIN
    NEW(ch);
    ch.char := char;
    int := self.Add(self, ch);
END push;


PROCEDURE Create* () : CharacterStackType;
    VAR l : CharacterStackType;
 BEGIN
    NEW(l);
    l.First   := NIL;
    l.Last    := NIL;
    l.Count   := 0;
    l.Add     := List.Add;
    l.Append  := List.Append;
    l.AppendList  := List.AppendList;
    l.Clear   := List.Clear;
    l.Free    := List.Free;
    l.Insert  := List.Insert;
    l.Delete  := List.Delete;
    l.Empty   := List.Empty;
    l.Get     := List.Get;
    l.res     := TRUE;
    
    l.pop := pop;
    l.push:= push;
    (* l.top := top; *)
    RETURN(l);
END Create;

VAR
 characterStack: CharacterStackType;
BEGIN
    NEW(characterStack);
    characterStack.push(characterStack, 'a');
    characterStack.push(characterStack, 'b');
    characterStack.push(characterStack, 'c');
    Out.Char(characterStack.pop(characterStack));
    Out.Ln();
    Out.Char(characterStack.pop(characterStack));
    Out.Ln();
    Out.Char(characterStack.pop(characterStack));
    Out.Ln();
    Out.Char(characterStack.pop(characterStack));
    Out.Ln();
END CharaterStack.