MODULE Logger;
IMPORT time, Out;

PROCEDURE Log*(buff: ARRAY OF CHAR);
VAR 
    year, month, day, hour, min, sec: LONGINT;
BEGIN
    time.Now(year, month, day, hour, min, sec);
    
    Out.Int(year, 4);
    Out.String("/");
    Out.Int(month, 2);
    Out.String("/");
    Out.Int(day, 2);
    Out.String(" "); 
    Out.Int(hour, 2);
    Out.String("-"); 
    Out.Int(min, 2);
    Out.String("-");
    Out.Int(sec, 2);
    Out.String(" ");
    Out.String(buff);
    Out.Ln;
END Log;

END Logger.