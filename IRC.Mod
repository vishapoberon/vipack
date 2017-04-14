MODULE IRC;
IMPORT Internet, Out, Strings := ooc2Strings, types;

CONST 
  msgLen* = 512; (* message length not more than 512 characters *)
  cmdPing* = "PING";
  cmdPong* = "PONG";
  zzo*  = "001";
  cmdMode*  = "MODE";
  cmdJoin* =  "JOIN";
  cmdUser* =  "USER";
  cmdNick* =  "NICK";
  CR* = 0DX;
  LF* = 0AX;

  TYPE 
    chn* = ARRAY 32 OF CHAR;
    chnlist* = POINTER TO ARRAY OF chn;


VAR
  connection : Internet.Socket;
  eol* : ARRAY 3 OF CHAR;
  channelList: chnlist;

PROCEDURE setChannelList*(VAR chnl: chnlist);
BEGIN
  channelList := chnl;
END setChannelList;

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
    UNTIL i = pos; 
    dst[i] := src[i];
    INC(i);
    dst[i] := 0X;
  END; 
END cutLine;


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

PROCEDURE Auth*(user, owner, nick: ARRAY OF CHAR): BOOLEAN;
VAR
	userRequest, nickRequest: ARRAY 255 OF CHAR;
  b : BOOLEAN;
BEGIN

  formUserLine(user, owner, userRequest);

    Out.String("sending:"); Out.Ln;
    Out.String(userRequest); Out.Ln;

  b := Internet.Write(connection, userRequest);

  IF b THEN Out.String("wrote!"); Out.Ln ELSE Out.String("write failed"); Out.Ln END;
  
  formNickLine(nick, nickRequest);

    Out.String("sending:"); Out.Ln;
    Out.String(nickRequest); Out.Ln;

  IF b THEN Out.String("wrote!"); Out.Ln ELSE Out.String("write failed"); Out.Ln END;

  RETURN b
END Auth;

PROCEDURE Receive*(VAR str: ARRAY OF CHAR): BOOLEAN;
VAR
  b: BOOLEAN;
BEGIN
  b := Internet.Read(connection, str);
  IF b THEN
    Out.String("received:"); Out.Ln;
    Out.String(str); Out.Ln;
  ELSE
    Out.String("receive failed"); Out.Ln;
  END;
  RETURN b
END Receive;

PROCEDURE Send*(str: ARRAY OF CHAR): BOOLEAN;
VAR
  b : BOOLEAN;
BEGIN
  b := Internet.Write(connection, str);
  IF b THEN
    Out.String("sent:"); Out.Ln;
    Out.String(str); Out.Ln;
  ELSE
    Out.String("sending failed"); Out.Ln;
  END;
  RETURN b
END Send;

PROCEDURE Connect*(host, port: ARRAY OF CHAR): BOOLEAN;
VAR
  res: BOOLEAN;
BEGIN
  res := Internet.Connect(host, port, connection);
  RETURN res
END Connect;

PROCEDURE Disconnect*;
BEGIN
  Internet.Disconnect(connection);
END Disconnect;

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

PROCEDURE Pong(VAR line: ARRAY OF CHAR);
VAR
  tmp: ARRAY msgLen OF CHAR;
  b : BOOLEAN;
BEGIN
      cutLine(line, tmp);
      tmp[1] := 'O'; (* replace "PING" by "PONG" *)
      b := Send(tmp);
END Pong;

PROCEDURE processResponse(VAR line: ARRAY OF CHAR);
BEGIN
  IF isPing(line) THEN Pong(line) END;
(*
    IF line[0] = ':' THEN
      IF contains001(line) THEN
         sendMode(line);
         sendJoin;
      END;
      Strings.FindNext(IRC.zzo, str, 0, patternFound, patternPos);
      IF patternFound THEN
        Out.String("001 found"); Out.Ln;
        COPY ("MODE ", str3);
        Strings.Append(nick, str3);
        Strings.Append(" +B", str3);
        Strings.Append(eol, str3);
        Strings.Append(0X, str3);
        b2 := IRC.Send(str3);
        COPY("JOIN ", str3);
        Strings.Append("#oberon", str3);
        Strings.Append(eol, str3);
        Strings.Append(0X, str3);
        b2 := IRC.Send(str3);
      END;
    END;*)
END processResponse;

PROCEDURE Loop*;
VAR
  b : BOOLEAN;
  str : ARRAY msgLen OF CHAR;
BEGIN
  REPEAT
    b := Receive(str);
    processResponse(str);
  UNTIL ~b;
END Loop;

BEGIN
  eol[0] := LF; eol[1] := CR; eol[2] := 0X;


END IRC.
