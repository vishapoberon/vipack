MODULE irc;
IMPORT sockets, netdb, Platform, Strings, types, Out, SYSTEM;

CONST strLen = 1024;

TYPE
  Int16 = types.Int16;
  Int32 = types.Int32;
  Int64 = types.Int64;


VAR
nick*, channel*, host*, port*, user*, command*, where*, message*, sep*, target*: ARRAY strLen OF CHAR;

PROCEDURE rawWrite(fd: Int32; VAR buf: ARRAY OF CHAR; len: LONGINT);
VAR
   l: SYSTEM.ADDRESS;
   r: INTEGER;
BEGIN
  l := SYSTEM.ADR(buf);
  r := Platform.Write(fd, l, len);
  IF r = -1 THEN
    Out.String("write() failed."); Out.Ln;
    HALT(1);
  ELSE
    Out.String("write() success."); Out.Ln;
  END;
END rawWrite;

PROCEDURE connect*;
VAR hints, res : netdb.addrInfo;
    pres, pres2, phints: netdb.PaddrInfo;
    tmpaddr : SYSTEM.ADDRESS;
	tmp32 : netdb.Int32;
	conn : netdb.Int32;
	str0, str1: ARRAY 255 OF CHAR;
BEGIN
  (*NEW(phints);*)
  (*hints.aiFamily := sockets.AfInet;*)
  hints.aiFamily := sockets.AfUnspec;
	hints.aiSockType := sockets.SockStream;
	hints.aiFlags := 0;
	hints.aiProtocol := netdb.ipprotoTCP;
	hints.aiAddrLen := 0;
	hints.aiAddr := 0; hints.aiCanonName := 0; hints.aiNext := 0;

  (*NEW(pres);*)
  phints := SYSTEM.VAL(netdb.PaddrInfo, SYSTEM.ADR(hints));
  pres := SYSTEM.VAL(netdb.PaddrInfo, SYSTEM.ADR(res));
  pres2 := SYSTEM.VAL(netdb.PaddrInfo, SYSTEM.ADR(pres));
	tmp32 := netdb.getAddrInfo(host, port, phints, pres2);
  IF tmp32 # 0 THEN
    Out.String("getaddrinfo() failed"); Out.Ln;
    HALT(1);
  ELSE
    Out.String("getaddrinfo() returned 0, success"); Out.Ln;
  END;
  conn := sockets.Socket(pres^.aiFamily, pres^.aiSockType, pres^.aiProtocol);
  IF conn = -1 THEN
    Out.String("socket() returned -1, error"); Out.Ln;
    HALT(1);
  ELSE
    Out.String("socket() succeeded."); Out.Ln;
  END;
  tmpaddr := SYSTEM.ADR(pres^.aiAddr);
	tmp32 := sockets.Connect(conn, pres^.aiAddr, pres^.aiAddrLen);
  IF tmp32 = 0 THEN
    Out.String("connect() succeeded."); Out.Ln;
  ELSE
    Out.String("connect() failed."); Out.Ln; HALT(1);
  END;

(* "USER test 0 0 :test\r\n" *)
(* "NICK test\r\n\000\060 :test\r\n"*)
    COPY("USER ", str0);
	Strings.Append(user, str0);
    Strings.Append(" 0 0 :", str0);
	Strings.Append(nick, str0);
	str1[0] := 0AX; str1[1] := 0DX; str1[2] := 0X;
	Strings.Append(str1, str0);
	rawWrite(conn, str0, Strings.Length(str0));
END connect;

BEGIN

END irc.
