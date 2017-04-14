MODULE IRC;
IMPORT Internet, Out, Strings := ooc2Strings, types;

CONST 
  msgLen* = 512; (* message length not more than 512 characters *)
  ping* = "PING";
  pong* = "PONG";
  zzo*  = "001";
  mode*  = "MODE";
  join* =  "JOIN";

VAR
  connection : Internet.Socket;
  eol* : ARRAY 3 OF CHAR;

PROCEDURE Auth*(user, nick, owner: ARRAY OF CHAR): BOOLEAN;
VAR
	str0, str1: ARRAY 255 OF CHAR;
  b : BOOLEAN;
BEGIN
(* "USER test 0 * :test\r\n" *)
(* "NICK test\r\n\000\060 :test\r\n"*)


  COPY("USER ", str0);
	Strings.Append(user, str0);
  Strings.Append(" 0 * :", str0);
	Strings.Append(owner, str0);
  (* by the spec the command is terminated by \r\n *)
	Strings.Append(eol, str0);

  Strings.Append ("NICK ", str0);
  Strings.Append (nick, str0);
	Strings.Append(eol, str0);
	Strings.Append(0X, str0);

  Out.String("sending:"); Out.Ln;
  Out.String(str0); Out.Ln;
	b := Internet.Write(connection, str0);

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

PROCEDURE Loop*;

BEGIN


END Loop;

BEGIN
  eol[0] := 0AX; eol[1] := 0DX; eol[2] := 0X;


END IRC.
