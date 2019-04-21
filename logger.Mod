MODULE Logger;
IMPORT time, Out;

PROCEDURE LogInt*(number: LONGINT);
VAR 
    i: LONGINT;
BEGIN
    WHILE number>10 DO
        number := number DIV 10;
        INC(i);
    END;
    
    Out.Int(number, i);
END LogInt;

PROCEDURE Log*(buff: ARRAY OF CHAR);
VAR 
    year, month, day, hour, min, sec: LONGINT;
BEGIN
    time.Now(year, month, day, hour, min, sec);
    
    LogInt(year);
    Out.String("/");
    LogInt(month);
    Out.String("/");
    LogInt(day);
    Out.String(" "); 
    LogInt(hour);
    Out.String("-"); 
    LogInt(min);
    Out.String("-");
    LogInt(sec);
    Out.String(" ");
    Out.String(buff);
    Out.Ln;
END Log;

END Logger.