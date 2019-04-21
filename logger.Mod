MODULE Logger;
IMPORT time, Out;

CONST
    deca = 10;

PROCEDURE GetDecas(number: LONGINT): LONGINT;
VAR 
    i: LONGINT;
BEGIN
    i := 1;

    WHILE number > deca DO
        number := number DIV deca;
        INC(i);
    END;

    RETURN i;
END GetDecas;

PROCEDURE LogInt*(number: LONGINT);
BEGIN      
    Out.Int(number, GetDecas(number));
END LogInt;


PROCEDURE LogNormalized*(number, normal: LONGINT);
VAR
    decimals, i: LONGINT;
BEGIN   
    i:=0; 
    decimals := GetDecas(number);
    WHILE decimals + i < normal DO 
        INC(i);
        Out.Int(0, 1)
    END;

    LogInt(number);
END LogNormalized;

PROCEDURE Log*(buff: ARRAY OF CHAR);
VAR 
    year, month, day, hour, min, sec: LONGINT;
BEGIN
    time.Now(year, month, day, hour, min, sec);
    
    LogNormalized(year, 4);
    Out.String("/");
    LogNormalized(month, 2);
    Out.String("/");
    LogNormalized(day, 2);
    Out.String(" "); 
    LogNormalized(hour, 2);
    Out.String("-"); 
    LogNormalized(min, 2);
    Out.String("-");
    LogNormalized(sec, 2);
    Out.String(" ");
    Out.String(buff);
    Out.Ln;
END Log;

END Logger.