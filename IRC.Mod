MODULE IRC;
IMPORT Internet, Out, Strings, types;

CONST msgLen = 512; (* message length not more than 512 characters *)

VAR
  connection : Internet.Socket;

PROCEDURE Auth*(user, nick, owner: ARRAY OF CHAR): BOOLEAN;
VAR
	str0, str1: ARRAY 255 OF CHAR;
  b : BOOLEAN;
BEGIN
(* "USER test 0 * :test\r\n" *)
(* "NICK test\r\n\000\060 :test\r\n"*)

  str1[0] := 0AX; str1[1] := 0DX; str1[2] := 0X;

  COPY("USER ", str0);
	Strings.Append(user, str0);
  Strings.Append(" 0 0 :", str0);
	Strings.Append(owner, str0);
  (* by the spec the command is terminated by \r\n *)
	Strings.Append(str1, str0);
  Out.String("sending:"); Out.Ln;
  Out.String(str0); Out.Ln;
	b := Internet.Write(connection, str0, Strings.Length(str0));
  IF b THEN Out.String("wrote!"); Out.Ln ELSE Out.String("write failed"); Out.Ln END;
  COPY ("NICK ", str0);
  Strings.Append (nick, str0);
	Strings.Append(str1, str0);
  IF b THEN Out.String("wrote!"); Out.Ln ELSE Out.String("write failed"); Out.Ln END;
  RETURN b

END Auth;

PROCEDURE Connect*(host, port: ARRAY OF CHAR): BOOLEAN;
VAR
  res: BOOLEAN;
BEGIN
  res := Internet.Connect(host, port, connection);
  RETURN res
END Connect;

END IRC.
