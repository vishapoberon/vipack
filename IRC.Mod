MODULE IRC;
IMPORT Internet, Out, Strings := ooc2Strings, types;

CONST 
  msgLen* = 512; (* message length not more than 512 characters *)
  cmdPing* = "PING";
  cmdPong* = "PONG";
  cmdMode*  = "MODE";
  cmdJoin* =  "JOIN";
  cmdUser* =  "USER";
  cmdNick* =  "NICK";
  CR* = 0DX;
  LF* = 0AX;

  numRPLWELCOME = "001";
  numRPLYOURHOST = "002";
  numRPLCREATED = "003";
  numRPLMYINFO = "004";

  eofMOTD="End of /MOTD";
  errClosingLink = "ERROR :Closing Link:";

  TYPE 
    chn* = ARRAY 32 OF CHAR;
    chnlist* = POINTER TO ARRAY OF chn;
    msg* = ARRAY msgLen OF CHAR;
    callBack* = PROCEDURE(VAR in: ARRAY OF CHAR);


    instance* = RECORD
     owner*, user*, nick*, host*, port*: chn;
     connection*: Internet.Socket;
     channelList*: chnlist;
     callback*: callBack;
    END;


VAR
  eol* : ARRAY 3 OF CHAR;

(* string operations *)

PROCEDURE findChar(ch: CHAR; VAR line: ARRAY OF CHAR; VAR b: BOOLEAN; VAR pos: INTEGER);
VAR
  i : INTEGER;
BEGIN
  i := -1; pos := -1;
  b := FALSE;
  REPEAT
    INC(i);
    IF line[i] = ch THEN b := TRUE; pos := i END;
  UNTIL b OR (i = LEN(line) - 1);
END findChar;

(* cuts line, takes the part till the eol *)
PROCEDURE cutLine(VAR src, dst: ARRAY OF CHAR);
VAR
 found: BOOLEAN;
 pos : INTEGER;
 i : INTEGER;
BEGIN
  COPY("", dst);
  findChar(LF, src, found, pos);
  IF found THEN
    i := 0;
    REPEAT
      dst[i] := src[i];
      INC(i);
    UNTIL (i = pos) OR (i = LEN(dst)-2); 
    dst[i] := src[i];
    dst[i+1] := 0X
  END; 
END cutLine;

PROCEDURE terminateLine(VAR str: ARRAY OF CHAR);
VAR
 found: BOOLEAN;
 pos : INTEGER;
BEGIN
  findChar(LF, str, found, pos);
  IF found THEN
    IF (pos + 1) < LEN(str) THEN
      str[pos + 1] := 0X
    END
  END; 
END terminateLine;

PROCEDURE formUserNickLine(VAR user, owner, nick, res: ARRAY OF CHAR);
BEGIN
  COPY(cmdUser, res);
	Strings.Append(" ", res);
	Strings.Append(user, res);
  Strings.Append(" 0 * :", res);
	Strings.Append(owner, res);
  (* by the spec the command is terminated by \r\n *)
	Strings.Append(eol, res);

  Strings.Append (cmdNick, res);
  Strings.Append(" ", res);
  Strings.Append (nick, res);
	Strings.Append(eol, res);

END formUserNickLine;

PROCEDURE formModeLine(VAR str, nick: ARRAY OF CHAR);
BEGIN
        COPY (cmdMode, str);
        Strings.Append(" ", str);
        Strings.Append(nick, str);
        Strings.Append(" +C", str);
        Strings.Append(eol, str);
END formModeLine;

PROCEDURE formJoinLine(VAR ln, chan: ARRAY OF CHAR);
BEGIN
        COPY(cmdJoin, ln);
        Strings.Append(" ", ln);
        Strings.Append(chan, ln);
        Strings.Append(eol, ln);
END formJoinLine;

PROCEDURE formModeJoinLine(VAR str, nick, chan: ARRAY OF CHAR);
BEGIN
        COPY (cmdMode, str);
        Strings.Append(" ", str);
        Strings.Append(nick, str);
        Strings.Append(" +C", str);
        Strings.Append(eol, str);

        Strings.Append(cmdJoin, str);
        Strings.Append(" ", str);
        Strings.Append(chan, str);
        Strings.Append(eol, str);
END formModeJoinLine;

PROCEDURE isPing(VAR line: ARRAY OF CHAR): BOOLEAN;
VAR
 tmp: ARRAY 5 OF CHAR;
BEGIN
    Strings.Extract(line, 0, 4, tmp);
    IF Strings.Equal(tmp, cmdPing) THEN
      RETURN TRUE
    ELSE
      RETURN FALSE
    END
END isPing;

PROCEDURE serverMsg(VAR line: ARRAY OF CHAR): BOOLEAN;
BEGIN
  IF line[0] = ':' THEN RETURN TRUE ELSE RETURN FALSE END
END serverMsg;

PROCEDURE contains (VAR line : ARRAY OF CHAR; pattern: ARRAY OF CHAR): BOOLEAN;
VAR
 found: BOOLEAN;
 pos : INTEGER;
 i : INTEGER;
 patternLength: INTEGER;
 tmpline: POINTER TO ARRAY OF CHAR;
BEGIN
  i := 0;
  patternLength := Strings.Length(pattern);
  NEW(tmpline, patternLength+1);
  found := FALSE;
  REPEAT
    Strings.Extract(line, i, patternLength, tmpline^);
    Out.String("COMPARING: "); Out.String(pattern); Out.String (" "); Out.String (tmpline^); Out.Ln;
    found := Strings.Equal(pattern, tmpline^);
    INC(i);
UNTIL found OR (i = LEN(line) - patternLength - 1);
  IF found THEN RETURN TRUE ELSE RETURN FALSE END
END contains;

PROCEDURE rplWelcome(VAR line : ARRAY OF CHAR): BOOLEAN;
VAR
 found: BOOLEAN;
 pos : INTEGER;
BEGIN
  Strings.FindNext(numRPLWELCOME, line, 0, found, pos);
  IF found THEN RETURN TRUE ELSE RETURN FALSE END
END rplWelcome;

PROCEDURE error(VAR line: ARRAY OF CHAR): BOOLEAN;
VAR
  b : BOOLEAN;
  pos: INTEGER;
BEGIN
  Strings.FindNext(errClosingLink, line, 0, b, pos);
  RETURN b
END error;

(* instance functions *)

PROCEDURE setChannelList*(VAR inst: instance; chnl: chnlist);
BEGIN
  inst.channelList := chnl;
END setChannelList;

PROCEDURE Receive*(VAR inst: instance; VAR str: ARRAY OF CHAR): BOOLEAN;
VAR
  b: BOOLEAN;
BEGIN
  b := Internet.Read(inst.connection, str);
  IF b THEN
    Out.String("received:"); Out.Ln;
    Out.String(str); Out.Ln;
  ELSE
    Out.String("receive failed"); Out.Ln;
  END;
  RETURN b
END Receive;

PROCEDURE Send*(VAR inst: instance; str: ARRAY OF CHAR): BOOLEAN;
VAR
  b : BOOLEAN;
BEGIN
  terminateLine(str);
  b := Internet.Write(inst.connection, str);
  IF b THEN
    Out.String("sent:"); Out.Ln;
    Out.String(str); Out.Ln;
  ELSE
    Out.String("sending failed"); Out.Ln;
  END;
  RETURN b
END Send;

PROCEDURE Auth*(inst: instance): BOOLEAN;
VAR
	line: ARRAY 255 OF CHAR;
  b : BOOLEAN;
BEGIN
  formUserNickLine(inst.user, inst.owner, inst.nick, line);

  b := Internet.Write(inst.connection, line);

  RETURN b
END Auth;

PROCEDURE Connect*(VAR inst: instance): BOOLEAN;
VAR
  res: BOOLEAN;
BEGIN
  res := Internet.Connect(inst.host, inst.port, inst.connection);
  RETURN res
END Connect;

PROCEDURE Disconnect*(VAR inst: instance);
BEGIN
  Internet.Disconnect(inst.connection);
END Disconnect;

PROCEDURE Pong(VAR inst: instance; VAR line: ARRAY OF CHAR);
VAR
  tmp: ARRAY msgLen OF CHAR;
  b : BOOLEAN;
BEGIN
      cutLine(line, tmp);
      tmp[1] := 'O'; (* replace "PING" by "PONG" *)
      b := Send(inst, tmp);
END Pong;

PROCEDURE Mode*(VAR inst: instance);
VAR
  str : ARRAY msgLen OF CHAR;
  b : BOOLEAN;
BEGIN
        formModeLine(str, inst.nick);
        b := Send(inst, str);
END Mode;

PROCEDURE ModeAndJoin*(VAR inst : instance);
VAR str: ARRAY msgLen OF CHAR;
    b: BOOLEAN;
BEGIN
         formModeJoinLine(str, inst.nick, inst.channelList^[0]);
         b := Send(inst, str);
END ModeAndJoin;

PROCEDURE Join*(VAR inst: instance);
VAR
  str: ARRAY msgLen OF CHAR;
  b: BOOLEAN;
BEGIN
  formJoinLine(str, inst.channelList^[0]);
  Out.String("SENDING JOIN LINE"); Out.Ln;
  b := Send(inst, str);
  (*b := Internet.Write(inst.connection, str);*)
END Join;

PROCEDURE processResponse(VAR inst: instance; VAR line: ARRAY OF CHAR): BOOLEAN;
VAR
  b : BOOLEAN;
BEGIN
  b := TRUE;
  IF isPing(line) THEN 
    Pong(inst, line);
  END;
  IF error(line) THEN
    Disconnect(inst);
    b := FALSE;
  ELSE
    (*IF serverMsg(line) THEN*)
      IF rplWelcome(line) THEN
      (*IF contains(line, eofMOTD) THEN*)
         (*Mode(inst);
         Join(inst);*)
         ModeAndJoin(inst);
      ELSE
         inst.callback(line); 
      END;
    (*END;*)
  END;
  RETURN b;
END processResponse;

PROCEDURE Loop*(VAR inst: instance);
VAR
  b, b2 : BOOLEAN;
  str : ARRAY msgLen OF CHAR;
BEGIN
  REPEAT
    b := Receive(inst, str);
    b2 := processResponse(inst, str);
  UNTIL ~b OR ~b2;
END Loop;

BEGIN
  eol[0] := LF; eol[1] := CR; eol[2] := 0X;
END IRC.
