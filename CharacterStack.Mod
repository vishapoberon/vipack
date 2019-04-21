MODULE CharacterStack;
IMPORT List, Out, Sys;

TYPE 
    integer* = Sys.integer;
    TObject* = Sys.TObject;

    Node* = POINTER TO NodeDesc;
    NodeDesc* = List.NodeDesc;

    TChar* = POINTER TO TCharDesc;
    
    TCharDesc = RECORD (Sys.TObjectDesc)
        char* : CHAR
    END;

    string = Sys.string;

    CharacterStackType* = POINTER TO CharacterStackTypeDesc;
    
    CharacterStackTypeDesc* = RECORD (List.TListDesc)
        pop: PROCEDURE(self: CharacterStackType): CHAR;
        push: PROCEDURE(self: CharacterStackType; char: CHAR);
        top: PROCEDURE(self: CharacterStackType) : CHAR;
    END;

VAR
 characterStack: CharacterStackType;

PROCEDURE push(self: CharacterStackType; char: CHAR);
VAR
    ch: TChar;
    int: integer;
BEGIN
    NEW(ch);
    ch.char := char;
    int := self.Add(self, ch);
END push;

PROCEDURE pop(self: CharacterStackType): CHAR;
VAR
    n: Node;
BEGIN
    NEW(n);
    
    IF self.Count = 0 THEN RETURN 0AX END;
    
    n := self.Get(self, self.Count - 1);
    self.Delete(self, self.Count - 1);
    RETURN n.obj(TChar).char;
END pop;

PROCEDURE top(self: CharacterStackType): CHAR;
VAR
    n: Node;
BEGIN
    NEW(n);
    
    IF self.Count = 0 THEN RETURN 0AX END;
    
    n := self.Get(self, self.Count - 1);
    RETURN n.obj(TChar).char;
END top;

PROCEDURE Create* () : CharacterStackType;
VAR
    l : CharacterStackType;
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
    l.top := top;
    RETURN(l);
END Create;

BEGIN
    (* NEW(characterStack);
    characterStack := Create();
    characterStack.push(characterStack, 'a');
    characterStack.push(characterStack, 'b');
    characterStack.push(characterStack, 'c');
    
    Out.Char(characterStack.top(characterStack));
    Out.Ln();
    Out.Char(characterStack.pop(characterStack));
    Out.Ln();
    Out.Char(characterStack.top(characterStack));
    Out.Ln();
    Out.Char(characterStack.pop(characterStack));
    Out.Ln();
    Out.Char(characterStack.top(characterStack));
    Out.Ln();
    Out.Char(characterStack.pop(characterStack));
    Out.Ln();
    Out.Char(characterStack.top(characterStack));
    Out.Ln();
    Out.Char(characterStack.pop(characterStack));
    Out.Ln();
    Out.Char(characterStack.top(characterStack));
    Out.Ln();
    Out.Char(characterStack.pop(characterStack));
    Out.Ln();
    Out.Char(characterStack.top(characterStack));
    Out.Ln();
    Out.Char(characterStack.pop(characterStack));
    Out.Ln(); *)
END CharacterStack.