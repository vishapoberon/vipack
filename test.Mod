MODULE test;
IMPORT Out;
VAR
    string: POINTER TO ARRAY OF CHAR;
BEGIN
    NEW(string, 42);
    string[1] := "a";
    Out.Char(string[1]);
    Out.Ln();
    Out.Int(ORD(string[1]), 10);
    Out.Ln();
    Out.Int(ORD(string[2]), 10);
    Out.Ln();
    COPY("Gago", string);
END test.