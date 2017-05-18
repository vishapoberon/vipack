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
  msgPRIVMSG* = "PRIVMSG";
  msgNOTICE*  = "NOTICE";
  msg001 = "001";
  msg002 = "002";
  msg003 = "003";
  msg004 = "004";
  msg005 = "005";
  
  CR* = 0DX;
  LF* = 0AX;

  eofMOTD="End of /MOTD";
  errClosingLink = "ERROR :Closing Link:";

  TYPE 
    chn* = ARRAY 32 OF CHAR;
    chnlist* = POINTER TO ARRAY OF chn;
    msg* = ARRAY msgLen OF CHAR;
    cbMessage* = PROCEDURE(VAR msg : ARRAY OF CHAR); (* cb stands for callback *)
    cbPrivateMessage* = PROCEDURE (VAR msg, user, ident, host: ARRAY OF CHAR);
    cbPublicMessage*  = PROCEDURE (VAR msg, user, ident, rcpt, host: ARRAY OF CHAR);
    cbPublicMessageWithMention* = PROCEDURE(VAR msg, user, ident, rcpt, host: ARRAY OF CHAR); (* rcpt is usually the room in case of public messages *)


    instance* = RECORD
     owner*, user*, nick*, host*, port*: chn;
     connection*: Internet.Socket;
     channelList*: chnlist;
     callbackSimple*: cbMessage;
     callbackPrivate*: cbPrivateMessage;
     callbackPublic*: cbPublicMessage;
     callbackPublicMention*: cbPublicMessageWithMention;
    END;


VAR
  eol* : ARRAY 3 OF CHAR;

(* string operations *)

PROCEDURE zeroStr(VAR str: ARRAY OF CHAR);
VAR
  i, j : LONGINT;
BEGIN
  i := LEN(str);
  j := 0;
  REPEAT
    str[j] := 0X;
    INC(j)
  UNTIL j = i;
END zeroStr;

PROCEDURE appendLFCR(VAR str: ARRAY OF CHAR);
VAR
  l : INTEGER;
BEGIN
        l := Strings.Length(str);
        str[l] := LF;
        str[l+1] := CR;
        str[l+2] := 0X;
END appendLFCR;

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
VAR
  l : INTEGER;
BEGIN
  COPY(cmdUser, res);
	Strings.Append(" ", res);
	Strings.Append(user, res);
  Strings.Append(" 0 * :", res);
	Strings.Append(owner, res);
  (* by the spec the command is terminated by \r\n *)

  l := Strings.Length(res);
  res[l] := LF;
  res[l+1] := CR;
  res[l+2] := 0X;
	(*Strings.Append(eol, res);*)

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

PROCEDURE formModeJoinLine(VAR str, nick: ARRAY OF CHAR; channels: chnlist);
VAR
  i: LONGINT;
BEGIN
        COPY (cmdMode, str);
        Strings.Append(" ", str);
        Strings.Append(nick, str);
        Strings.Append(" +C", str);
        appendLFCR(str);
        (*Strings.Append(eol, str);*)
        
        i := 0;
        REPEAT
          Strings.Append(cmdJoin, str);
          Strings.Append(" ", str);
          Strings.Append(channels[i], str);
          INC(i);
          IF i = LEN(channels^) THEN
            Strings.Append(eol, str);
          ELSE
            appendLFCR(str);
          END;
        UNTIL  i = LEN(channels^);
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
 tmp: ARRAY 128 OF CHAR;
BEGIN
  Strings.FindNext(msg001, line, 0, found, pos);
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
  (*COPY ("", str);*)
  zeroStr(str);
  b := Internet.Read(inst.connection, str);
  IF b THEN
    Out.String("received:"); Out.Ln;
    Out.String(str); Out.String("|"); Out.Ln;
  ELSE
    Out.String("receive failed"); Out.Ln;
  END;
  RETURN b
END Receive;

PROCEDURE Send*(VAR inst: instance; str: ARRAY OF CHAR): BOOLEAN;
VAR
  b : BOOLEAN;
BEGIN
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
        zeroStr(str);
        formModeLine(str, inst.nick);
        b := Send(inst, str);
END Mode;

PROCEDURE ModeAndJoin*(VAR inst : instance);
VAR str: ARRAY msgLen OF CHAR;
    b: BOOLEAN;
BEGIN
         zeroStr(str);
         formModeJoinLine(str, inst.nick, inst.channelList);
         b := Send(inst, str);
END ModeAndJoin;

PROCEDURE Join*(VAR inst: instance);
VAR
  str: ARRAY msgLen OF CHAR;
  b: BOOLEAN;
BEGIN
  zeroStr(str);
  formJoinLine(str, inst.channelList^[0]);
  Out.String("SENDING JOIN LINE"); Out.Ln;
  b := Send(inst, str);
END Join;

PROCEDURE getUser(VAR line, user: ARRAY OF CHAR): BOOLEAN;
VAR
  pos: INTEGER;
  found: BOOLEAN;
BEGIN
  zeroStr(user);
  Strings.FindNext(" ", line, 1, found, pos);
  IF found THEN
    Strings.Extract(line, 1, pos - 1, user);
  END;
  RETURN found
END getUser;

PROCEDURE getMsgType(VAR line, mtype: ARRAY OF CHAR): BOOLEAN;
VAR
  pos0, pos1: INTEGER;
  found: BOOLEAN;
BEGIN
  zeroStr(mtype);
  Strings.FindNext(" ", line, 0, found, pos0);
  IF found THEN
     Strings.FindNext(" ", line, pos0+1, found, pos1);
     IF found THEN
       Strings.Extract(line, pos0 + 1, pos1 - pos0 - 1, mtype);
     END;
  END;
  RETURN found
END getMsgType;

PROCEDURE getNextWord(VAR src: ARRAY OF CHAR; spos: INTEGER; VAR dst: ARRAY OF CHAR);
VAR
  i, j: INTEGER;
BEGIN
  zeroStr(dst);
  i := 0;
  j := spos+1;
  REPEAT
    dst[i] := src[i+j]; 
  INC(i); 
  UNTIL (i+j = Strings.Length(src)) OR (src[i+j] <= ' ');
END getNextWord;

PROCEDURE getTillEOL(VAR src: ARRAY OF CHAR; spos: INTEGER; VAR dst: ARRAY OF CHAR); (* actually get till any character < ' ' *)
VAR
  i, j: INTEGER;
BEGIN
  zeroStr(dst);
  i := 0;
  j := spos+1;
  REPEAT
    dst[i] := src[i+j]; 
  INC(i); 
  UNTIL (i+j = Strings.Length(src)) OR (src[i+j] < ' ');
END getTillEOL;


PROCEDURE getRecipient(VAR line, room: ARRAY OF CHAR): BOOLEAN;
VAR
  pos0, pos1: INTEGER;
  found: BOOLEAN;
BEGIN
  zeroStr(room);
  Strings.FindNext(" ", line, 0, found, pos1);
  IF found THEN
     Strings.FindNext(" ", line, pos1+1, found, pos0);
     IF found THEN
       getNextWord(line, pos0, room);
     END;
  END;
  RETURN found
END getRecipient;

PROCEDURE getMsg(VAR line, msg: ARRAY OF CHAR): BOOLEAN;
VAR
  pos0, pos1: INTEGER;
  found: BOOLEAN;
BEGIN
  zeroStr(msg);
  Strings.FindNext(" ", line, 0, found, pos0);
  IF found THEN
     Strings.FindNext(" ", line, pos0+1, found, pos1);
     IF found THEN
        Strings.FindNext(" ", line, pos1+1, found, pos0);
        getTillEOL(line, pos0+1, msg);
     END;
  END;
  RETURN found
END getMsg;

PROCEDURE getUserName(VAR user, username: ARRAY OF CHAR): BOOLEAN;
VAR
  i: INTEGER;
  b: BOOLEAN;
BEGIN
  zeroStr(username);
  Strings.FindNext("!", user, 0, b, i);
  IF b THEN
    Strings.Extract(user, 0, i, username);
  END;
  RETURN b
END getUserName;

PROCEDURE getIdentName(VAR user, ident: ARRAY OF CHAR): BOOLEAN;
VAR
  i, j: INTEGER;
  b: BOOLEAN;
BEGIN
  zeroStr(ident);
  Strings.FindNext("~", user, 0, b, i);
  IF b THEN
    Strings.FindNext("@", user, i, b, j);
    IF b THEN
      Strings.Extract(user, i+1, j-i-1, ident);
    END;
  END;
  RETURN b;
END getIdentName;

PROCEDURE getHost(VAR user, host: ARRAY OF CHAR): BOOLEAN;
VAR
  i: INTEGER;
  b: BOOLEAN;
BEGIN
  zeroStr(host);
  Strings.FindNext("@", user, 0, b, i);
  IF b THEN
    Strings.Extract(user, i+1, Strings.Length(user)-i-1, host);
  END;
  RETURN b;
END getHost;

PROCEDURE isMention(VAR nick, line: ARRAY OF CHAR): BOOLEAN;
VAR
  i : INTEGER;
  str: ARRAY 32 OF CHAR;
BEGIN
  Strings.Extract(line, 0, Strings.Length(nick), str);
  IF str = nick THEN
    RETURN TRUE
  ELSE
    RETURN FALSE
  END;
END isMention;

PROCEDURE cutMentionFromMessage(VAR nick, msg: ARRAY OF CHAR);
BEGIN
 Strings.Delete(msg, 0, Strings.Length(nick) + 2);
END cutMentionFromMessage;

PROCEDURE  parse(VAR inst: instance; VAR line: ARRAY OF CHAR);
VAR
  message: ARRAY msgLen OF CHAR;
  user, username, identname   : ARRAY 64 OF CHAR;
  host: ARRAY 64 OF CHAR;
  messagetype: ARRAY 16 OF CHAR;
  rcpt: ARRAY 64 OF CHAR;
  b: BOOLEAN;
  mn: BOOLEAN;
BEGIN

  b := getUser(line, user);
  b := getMsgType(line, messagetype);
  b := getRecipient(line, rcpt);
  b := getMsg(line, message);


  IF messagetype = msgPRIVMSG THEN
     b := getUserName(user, username);
     b := getIdentName(user, identname);
     b := getHost(user, host);
  END;

  IF rcpt = inst.nick THEN (* private message *)
    inst.callbackPrivate(message, username, identname, host);
  ELSE
    mn := isMention(inst.nick, message); 
    IF mn THEN
      cutMentionFromMessage(inst.nick, message); 
      inst.callbackPublicMention(message, username, identname, rcpt, host);
    ELSE
    inst.callbackPublic(message, username, identname, rcpt, host);
    END;
  END;
END parse;


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
    IF serverMsg(line) THEN (* string starts with ':' *)
      IF rplWelcome(line) THEN (* string contains '001' *)
         ModeAndJoin(inst);
      ELSE
         parse(inst, line);
      END;
    END;
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
  eol[0] := LF; eol[1] := CR;
END IRC.
