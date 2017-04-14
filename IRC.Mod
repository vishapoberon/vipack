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

(* cuts line, takes the part till the eol *)
PROCEDURE cutLine(VAR src, dst: ARRAY OF CHAR);
VAR
 found: BOOLEAN;
 pos : INTEGER;
 i : INTEGER;
 pattern : ARRAY 1 OF CHAR;
BEGIN
  pattern[0] := LF;
  COPY("", dst);
  Strings.FindNext(pattern, src, 0, found, pos);
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
 pattern : ARRAY 1 OF CHAR;
BEGIN
  pattern[0] := LF;
  Strings.FindNext(pattern, str, 0, found, pos);
  IF found THEN
    IF (pos + 1) < LEN(str) THEN
      str[pos + 1] := 0X
    END
  END; 
END terminateLine;

PROCEDURE formUserLine(VAR user, owner, result: ARRAY OF CHAR);
BEGIN
(* "USER test 0 * :test\r\n" *)
  COPY(cmdUser, result);
	Strings.Append(" ", result);
	Strings.Append(user, result);
  Strings.Append(" 0 * :", result);
	Strings.Append(owner, result);
  (* by the spec the command is terminated by \r\n *)
	Strings.Append(eol, result);
END formUserLine;

PROCEDURE formNickLine(VAR nick, result: ARRAY OF CHAR);
BEGIN
(* "NICK test\r\n\000\060 :test\r\n"*)
  COPY (cmdNick, result);
  Strings.Append(" ", result);
  Strings.Append (nick, result);
	Strings.Append(eol, result);
END formNickLine;

PROCEDURE formModeLine(VAR str, nick: ARRAY OF CHAR);
BEGIN
        COPY (cmdMode, str);
        Strings.Append(" ", str);
        Strings.Append(nick, str);
        Strings.Append(" +B", str);
        Strings.Append(eol, str);
END formModeLine;

PROCEDURE formJoinLine(VAR ln, chan: ARRAY OF CHAR);
BEGIN
        COPY(cmdJoin, ln);
        Strings.Append(" ", ln);
        Strings.Append(chan, ln);
        Strings.Append(eol, ln);
END formJoinLine;

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

PROCEDURE rplWelcome(VAR line : ARRAY OF CHAR): BOOLEAN;
VAR
 found: BOOLEAN;
 pos : INTEGER;
 i : INTEGER;
BEGIN
  Strings.FindNext(numRPLWELCOME, line, 0, found, pos);
  IF found THEN RETURN TRUE ELSE RETURN FALSE END
END rplWelcome;


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
	userRequest, nickRequest: ARRAY 255 OF CHAR;
  b : BOOLEAN;
BEGIN

  formUserLine(inst.user, inst.owner, userRequest);

  b := Send(inst, userRequest);

  IF b THEN
    formNickLine(inst.nick, nickRequest);

    b := Send(inst, nickRequest); 
  END;
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

PROCEDURE Mode(VAR inst: instance);
VAR
  str : ARRAY msgLen OF CHAR;
  b : BOOLEAN;
BEGIN
        formModeLine(str, inst.nick);
        b := Send(inst, str);
END Mode;

PROCEDURE Join(VAR inst: instance);
VAR
  str: ARRAY msgLen OF CHAR;
  b: BOOLEAN;
BEGIN
  formJoinLine(str, inst.channelList^[0]);
  b := Send(inst, str);
END Join;

PROCEDURE processResponse(VAR inst: instance; VAR line: ARRAY OF CHAR);
BEGIN
  IF isPing(line) THEN Pong(inst, line) END;

  IF serverMsg(line) THEN
    IF rplWelcome(line) THEN
       Mode(inst);
       Join(inst);
    ELSE
       inst.callback(line); 
    END;
  END;
END processResponse;

PROCEDURE Loop*(VAR inst: instance);
VAR
  b : BOOLEAN;
  str : ARRAY msgLen OF CHAR;
BEGIN
  REPEAT
    b := Receive(inst, str);
    processResponse(inst, str);
  UNTIL ~b;
END Loop;

BEGIN
  eol[0] := LF; eol[1] := CR; eol[2] := 0X;


END IRC.
