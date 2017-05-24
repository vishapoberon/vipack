MODULE IRC; (*noch 23.2.2017 / 19.5.2017*)
IMPORT Internet, Out, Files, Strings := ooc2Strings, sh := stringHelpers, types, time;

CONST 
  msgLen* = 512; (* message length not more than 512 characters *)
  (* irc commands *)
  cmdPing*			=	"PING";
  cmdPong*			=	"PONG";
  cmdMode*			=	"MODE";
  cmdJoin*			= "JOIN";
  cmdUser*			= "USER";
  cmdNick*			= "NICK";
  msgPRIVMSG*		=	"PRIVMSG";
  msgNOTICE*  	= "NOTICE";
  msgQUIT*    	= "QUIT";
  msgJOIN*    	= "JOIN";
  msgPART*    	= "PART";
  ctcpChar*     = 01X;
  msgACTION*    = "ACTION";
  (* irc replies rfc1459 from https://www.alien.net.au/irc/irc2numerics.html *)
  rplWelcome		= "001";
  rplYourHost 	= "002";
  rplCreated 		= "003";
  rplMyInfo 		= "004";
  rplBounce 		= "005";
  rplNameReply 	= "353";
  rplEndOfNames = "366";
  
  CR* = 0DX;
  LF* = 0AX;

  eofMOTD="End of /MOTD";
  errClosingLink = "ERROR :Closing Link:";

  TYPE 
    chn* = ARRAY 32 OF CHAR;

    Channel*   = RECORD
      channel* : chn;
      logfile : Files.File;
      rider   : Files.Rider;
    END;
    
    Channels* = POINTER TO ARRAY OF Channel;

    msg* = ARRAY msgLen OF CHAR;
    (*cbMessage* = PROCEDURE(VAR msg : ARRAY OF CHAR);*) (* cb stands for callback *)
    cbPrivateMessage* = PROCEDURE (VAR msg, msgtype, user, ident, host: ARRAY OF CHAR);
    cbPublicMessage*  = PROCEDURE (VAR msg, msgtype, user, ident, rcpt, host: ARRAY OF CHAR);
    cbPublicMessageWithMention* = PROCEDURE(VAR msg, msgtype, user, ident, rcpt, host: ARRAY OF CHAR); (* rcpt is usually the room in case of public messages *)

    instance* = RECORD
     owner*, user*, nick*, host*, port*: chn;
     connection*: Internet.Socket;
     channelList*: Channels;
     callbackPrivate*: cbPrivateMessage;
     callbackPublic*: cbPublicMessage;
     callbackPublicMention*: cbPublicMessageWithMention;
     doLog : BOOLEAN;
    END;


VAR
  eol- : ARRAY 3 OF CHAR;
  debug: BOOLEAN;

PROCEDURE setLogging*(VAR inst: instance; state: BOOLEAN);
BEGIN
  inst.doLog := state;
END setLogging;

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

PROCEDURE formModeJoinLine(VAR str, nick: ARRAY OF CHAR; channels: Channels);
VAR
  i: LONGINT;
BEGIN
        COPY (cmdMode, str);
        Strings.Append(" ", str);
        Strings.Append(nick, str);
        Strings.Append(" +i", str);
        sh.appendLFCR(str);
        (*Strings.Append(eol, str);*)
        
        i := 0;
        REPEAT
          Strings.Append(cmdJoin, str);
          Strings.Append(" ", str);
          Strings.Append(channels^[i].channel, str);
          INC(i);
          IF i = LEN(channels^) THEN
            Strings.Append(eol, str);
          ELSE
            sh.appendLFCR(str);
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

PROCEDURE isServerMsg(VAR line: ARRAY OF CHAR): BOOLEAN;
BEGIN
  IF line[0] = ':' THEN RETURN TRUE ELSE RETURN FALSE END
END isServerMsg;

PROCEDURE error(VAR line: ARRAY OF CHAR): BOOLEAN;
VAR
  b : BOOLEAN;
  pos: INTEGER;
BEGIN
  Strings.FindNext(errClosingLink, line, 0, b, pos);
  RETURN b
END error;

(* instance functions *)

PROCEDURE initChannelList*(VAR inst: instance; VAR channels: Channels);
VAR
  i : INTEGER;
BEGIN
  IF inst.doLog THEN
    i := 0;
    REPEAT
      channels^[i].logfile := Files.Old(channels^[i].channel);
      IF channels^[i].logfile = NIL THEN
        channels^[i].logfile := Files.New(channels^[i].channel);
        Files.Set(channels^[i].rider, channels^[i].logfile, 0);
      ELSE
        Files.Set(channels^[i].rider, channels^[i].logfile, Files.Length(channels^[i].logfile));
      END;
            INC(i);
    UNTIL i = LEN(channels^);
  END;
  inst.channelList := channels;
END initChannelList;

PROCEDURE Receive*(VAR inst: instance; VAR str: ARRAY OF CHAR): BOOLEAN;
VAR
  b: BOOLEAN;
BEGIN
  sh.zeroStr(str);
  b := Internet.Read(inst.connection, str);
  IF b THEN
    Out.String("received: '"); 
    Out.String(str); Out.String("'"); Out.Ln;
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
      sh.cutLine(line, tmp);
      tmp[1] := 'O'; (* replace "PING" by "PONG" *)
      b := Send(inst, tmp);
END Pong;

PROCEDURE Mode*(VAR inst: instance);
VAR
  str : ARRAY msgLen OF CHAR;
  b : BOOLEAN;
BEGIN
        sh.zeroStr(str);
        formModeLine(str, inst.nick);
        b := Send(inst, str);
END Mode;

PROCEDURE ModeAndJoin*(VAR inst : instance);
VAR str: ARRAY msgLen OF CHAR;
    b: BOOLEAN;
BEGIN
         sh.zeroStr(str);
         formModeJoinLine(str, inst.nick, inst.channelList);
         b := Send(inst, str);
END ModeAndJoin;

PROCEDURE Join*(VAR inst: instance);
VAR
  str: ARRAY msgLen OF CHAR;
  b: BOOLEAN;
BEGIN
  sh.zeroStr(str);
  formJoinLine(str, inst.channelList^[0].channel);
  Out.String("SENDING JOIN LINE"); Out.Ln;
  b := Send(inst, str);
END Join;

PROCEDURE getUser(VAR line, user: ARRAY OF CHAR): BOOLEAN;
VAR
  pos: INTEGER;
  found: BOOLEAN;
BEGIN
  sh.zeroStr(user);
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
  sh.zeroStr(mtype);
  Strings.FindNext(" ", line, 0, found, pos0);
  IF found THEN
     Strings.FindNext(" ", line, pos0+1, found, pos1);
     IF found THEN
       Strings.Extract(line, pos0 + 1, pos1 - pos0 - 1, mtype);
     END;
  END;
  RETURN found
END getMsgType;

PROCEDURE getRecipient(VAR line, room: ARRAY OF CHAR): BOOLEAN;
VAR
  pos0, pos1: INTEGER;
  found: BOOLEAN;
BEGIN
  sh.zeroStr(room);
  Strings.FindNext(" ", line, 0, found, pos1);
  IF found THEN
     Strings.FindNext(" ", line, pos1+1, found, pos0);
     IF found THEN
       sh.getNextWord(line, pos0, room);
     END;
  END;
  RETURN found
END getRecipient;

PROCEDURE getMsg(VAR line, msg: ARRAY OF CHAR): BOOLEAN;
VAR
  pos0, pos1: INTEGER;
  found: BOOLEAN;
BEGIN
  sh.zeroStr(msg);
  Strings.FindNext(" ", line, 0, found, pos0);
  IF found THEN
     Strings.FindNext(" ", line, pos0+1, found, pos1);
     IF found THEN
        Strings.FindNext(" ", line, pos1+1, found, pos0);
        sh.getTillEOL(line, pos0+1, msg);
     END;
  END;
  RETURN found
END getMsg;

PROCEDURE getUserName(VAR user, username: ARRAY OF CHAR): BOOLEAN;
VAR
  i: INTEGER;
  b: BOOLEAN;
BEGIN
  sh.zeroStr(username);
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
  sh.zeroStr(ident);
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
  sh.zeroStr(host);
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


PROCEDURE formTimeString(VAR str: ARRAY OF CHAR);
VAR
  year, month, day, hour, minute, second: LONGINT;
  syear, smonth, sday, shour, sminute, ssecond: ARRAY 8 OF CHAR;
BEGIN

  time.Now(year, month, day, hour, minute, second);
  sh.IntToStr(year, syear);
  sh.IntToStr(month, smonth);
  sh.IntToStr(day, sday);
  sh.IntToStr(hour, shour);
  sh.IntToStr(minute, sminute);
  sh.IntToStr(second, ssecond);

  COPY(syear, str);
  Strings.Append("-", str);
  Strings.Append(smonth, str);
  Strings.Append("-", str);
  Strings.Append(sday, str);
  Strings.Append(" (", str);
  Strings.Append(shour, str);
  Strings.Append(":", str);
  Strings.Append(sminute, str);
  Strings.Append(":", str);
  Strings.Append(ssecond, str);
  Strings.Append(") ", str);
END formTimeString;

PROCEDURE log(VAR inst: instance; message, messagetype, username, identname, rcpt: ARRAY OF CHAR);
VAR
  i : INTEGER;
  b : BOOLEAN;
  str: ARRAY msgLen OF CHAR;
  tmp: ARRAY 16 OF CHAR;
  (* for searching for ACTION *)
  b0: BOOLEAN;
  j:  INTEGER;
  str0: ARRAY msgLen OF CHAR;
BEGIN
  IF inst.doLog THEN
    sh.zeroStr(str);
    Out.String("logging about: "); Out.String(username); Out.String(", "); Out.String(messagetype); Out.String(", "); Out.String(rcpt); Out.Ln;
    i := 0; b := FALSE;
    REPEAT
      Out.String("is "); Out.String(inst.channelList^[i].channel); Out.String("="); Out.String(rcpt); Out.String("?"); Out.Ln; 
      IF inst.channelList^[i].channel = rcpt THEN b := TRUE END;
      INC(i);
    UNTIL (i = LEN(inst.channelList^)) OR b;
    IF b THEN Out.String("yes!") ELSE Out.String("no!") END; Out.Ln;
    IF b OR (messagetype = msgPART) THEN (* we don't know from which channel user quits so we only write to log about it when he parts. *)
      DEC(i);
      formTimeString(str);
        IF messagetype = msgPRIVMSG THEN
          b0 := FALSE;
          Strings.FindNext(msgACTION, message, 1, b0, j);
          IF b0 THEN (* handle actions *)
            Strings.Append("***", str);
            Strings.Append(username, str);
            Strings.Append(" ", str);
            sh.getTillEOL(message, j+Strings.Length(msgACTION), str0); 
            Strings.Append(str0, str);
          ELSE
            Strings.Append(username, str);
            tmp := ": ";
            Strings.Append(tmp, str);
            Strings.Append(message, str);
          END;
      ELSIF messagetype = msgJOIN THEN
        Strings.Append(username, str);
        tmp := " joined ";
        Strings.Append (tmp, str);
        Strings.Append (rcpt, str);
      ELSIF (messagetype = msgPART) THEN
        Strings.Append(username, str);
        tmp := " has quit";
        Strings.Append(tmp, str);
      END;
      Out.String("writing to "); Out.String(rcpt); Out.String(" log: "); Out.String(str); Out.Ln;
      Files.WriteString(inst.channelList^[i].rider, str);
      Files.Set(inst.channelList^[i].rider, inst.channelList^[i].logfile, Files.Pos(inst.channelList^[i].rider)-1); Files.Write(inst.channelList^[i].rider, 0AX);
      Files.Register(inst.channelList^[i].logfile);
    END;
  END; (* if do log *)
END log;

PROCEDURE finalize*(VAR inst: instance);
VAR
  i: INTEGER;
  l: LONGINT;
  b: BOOLEAN;
  msg: ARRAY 23 OF CHAR;
BEGIN
  IF inst.doLog THEN
  i := 0;
  REPEAT
    Out.String("flushing "); Out.String(inst.channelList^[i].channel); Out.String(" file."); Out.Ln;
    Files.Register(inst.channelList^[i].logfile);
    Files.Close(inst.channelList^[i].logfile);
    INC(i)
  UNTIL i = LEN(inst.channelList^);
  END;
    Out.String("quitting."); Out.Ln;
  msg := "QUIT :interrupt";
  l := Strings.Length(msg);
  msg[l] := LF;
  msg[l+1] := CR;
  msg[l+2] := 0X;
  Out.String("closing connection."); Out.Ln;
	b := Send(inst, msg); 
  Disconnect(inst);
  Out.String("exiting."); Out.Ln;
END finalize;

PROCEDURE sendMsgToDst*(VAR inst: instance; VAR dst: ARRAY OF CHAR; msg: ARRAY OF CHAR);
VAR 
  s: POINTER TO ARRAY OF CHAR;
  i, j: LONGINT;
  b: BOOLEAN;
BEGIN
  i := Strings.Length(msg);
  j := Strings.Length(dst);
  NEW(s, i + j + Strings.Length(msgPRIVMSG) + 6(* to fit a colon and two spaces  and eol *));   
  COPY(msgPRIVMSG, s^);
  Strings.Append(' ', s^);
  Strings.Append(dst, s^);
  Strings.Append(' :', s^);
  Strings.Append(msg, s^);
  sh.appendLFCR(s^);
  Out.String("sending: "); Out.String(s^); Out.Ln;
  b := Send(inst, s^);
END sendMsgToDst;

PROCEDURE  processFurther(VAR inst: instance; VAR line: ARRAY OF CHAR);
VAR
  message: ARRAY msgLen OF CHAR;
  userpart, username, identname   : ARRAY 64 OF CHAR;
  host: ARRAY 64 OF CHAR;
  messagetype: ARRAY 16 OF CHAR;
  rcpt: ARRAY 64 OF CHAR;
  b: BOOLEAN;
  mn: BOOLEAN;
  i: INTEGER;
BEGIN
  i := 0; mn := FALSE; b := FALSE;
  b := getUser(line, userpart);
  b := getMsgType(line, messagetype);

  IF (messagetype = msgNOTICE) OR (messagetype = msgJOIN) OR
     (messagetype = msgQUIT)   OR (messagetype = msgPRIVMSG) OR
     (messagetype = msgPART) THEN

     IF messagetype = msgPRIVMSG THEN
        b := getUserName(userpart, username);
        b := getIdentName(userpart, identname);
        b := getHost(userpart, host);
        b := getRecipient(line, rcpt);
        b := getMsg(line, message);
     END;
     
     IF messagetype = msgNOTICE THEN
        username := "";
        identname := "";
        host := userpart;
        Strings.Delete(host, 0, 1);
        b := getRecipient(line, rcpt);
        b := getMsg(line, message);
     END;

     IF messagetype = msgJOIN THEN
        b := getUserName(userpart, username);
        b := getIdentName(userpart, identname);
        b := getHost(userpart, host);
        b := getRecipient(line, rcpt);
        message := "";
     END;

     IF (messagetype = msgQUIT) THEN
        b := getUserName(userpart, username);
        b := getIdentName(userpart, identname);
        b := getHost(userpart, host);
        rcpt := "";
        message := "";
        Strings.FindNext(":", line, 1, b, i);
        sh.getTillEOL(line, i, message);
     END;

     IF (messagetype = msgPART) THEN
        b := getUserName(userpart, username);
        b := getIdentName(userpart, identname);
        b := getHost(userpart, host);
        b := getRecipient(line, rcpt);
        message := "";
     END;

     IF rcpt = inst.nick THEN (* private message *)
       inst.callbackPrivate(message, messagetype, username, identname, host);
     ELSE
       mn := isMention(inst.nick, message); 
       IF mn THEN
         log(inst, message, messagetype, username, identname, rcpt);
         cutMentionFromMessage(inst.nick, message); 
         inst.callbackPublicMention(message, messagetype, username, identname, rcpt, host);
       ELSE
         log(inst, message, messagetype, username, identname, rcpt);
         inst.callbackPublic(message, messagetype, username, identname, rcpt, host);
       END;
     END;
  ELSE
     Out.String("unknown msg type: '"); Out.String(messagetype); Out.String("' - ignoring!"); Out.Ln; 
  END;
END processFurther;

PROCEDURE processLineByLine(VAR inst: instance; VAR text: ARRAY OF CHAR);
VAR
  i : INTEGER;
  pstrs: sh.pstrings;
BEGIN
  pstrs := sh.textToPstrings(text);
  i := 0;
  REPEAT
     Out.Int(i, 0); Out.String(": '"); Out.String(pstrs^[i]^); Out.String("'"); Out.Ln;
     processFurther(inst, pstrs^[i]^); 
     INC(i)
  UNTIL i = LEN(pstrs^);
END processLineByLine;

PROCEDURE processResponse(VAR inst: instance; VAR text: ARRAY OF CHAR): BOOLEAN;
VAR
  b : BOOLEAN;
BEGIN
  b := TRUE;
  IF isPing(text) THEN 
    Pong(inst, text);
  END;
  IF error(text) THEN
    finalize(inst);
    b := FALSE;
  ELSE
    IF isServerMsg(text) THEN (* string starts with ':' *)
      IF sh.contains1(text, rplWelcome) THEN (* string contains '001' *)
         ModeAndJoin(inst);
      ELSE
         processLineByLine(inst, text);
      END;
    END;
  END;
  RETURN b;
END processResponse;

PROCEDURE Loop*(VAR inst: instance);
VAR
  b, b2 : BOOLEAN;
  txt : ARRAY msgLen OF CHAR;
BEGIN
  REPEAT
    b := Receive(inst, txt);
    b2 := processResponse(inst, txt);
  UNTIL ~b OR ~b2;
END Loop;

PROCEDURE setDebug*(state: BOOLEAN);
BEGIN
  debug := state
END setDebug;

BEGIN
  eol[0] := LF; eol[1] := CR;
  debug := FALSE;
END IRC.
