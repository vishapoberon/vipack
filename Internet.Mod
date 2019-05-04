MODULE Internet; (*noch 14.4.2017 / 14.4.2017*)
IMPORT sockets, netdb, types, Strings, Out, Platform, SYSTEM;

TYPE 

  Socket* = LONGINT; (* INT32 *)

  Int16 = types.Int16;
  Int32 = types.Int32;
  Int64 = types.Int64;

PROCEDURE Write*(fd: Socket; buf: ARRAY OF CHAR): BOOLEAN;
VAR
   l: SYSTEM.ADDRESS;
   r: INTEGER;
 len: LONGINT;
BEGIN
  l := SYSTEM.ADR(buf[0]);
  len := Strings.Length(buf)-1;
  r := Platform.Write(fd, l, len);
  IF r = -1 THEN
    (*Out.String("write() failed."); Out.Ln;*)
    RETURN FALSE
  ELSE
    (*Out.String("write() success."); Out.Ln;*)
    RETURN TRUE
  END;
END Write;

PROCEDURE Read*(fd: Socket; VAR buf: ARRAY OF CHAR): BOOLEAN;
VAR
  p: SYSTEM.ADDRESS;
  l, f: LONGINT;
  r: INTEGER;
BEGIN
  p := SYSTEM.ADR(buf[0]);
  l := LEN(buf)-1;
  f := 0;
  r := Platform.Read(fd, p, l, f);
  IF r > 0 THEN RETURN TRUE ELSE RETURN FALSE END
END Read;

PROCEDURE Connect*(host, port: ARRAY OF CHAR; VAR conn: Socket): BOOLEAN;
VAR
  hints, res : netdb.addrInfo;
  pres, pres2, phints: netdb.PaddrInfo;
  tmpaddr : SYSTEM.ADDRESS;
  tmp32 : netdb.Int32;
  (*conn : netdb.Int32;*)
BEGIN
  hints.aiFamily := sockets.AfUnspec;
  hints.aiSockType := sockets.SockStream;
  hints.aiFlags := 0;
  hints.aiProtocol := netdb.ipprotoTCP;
  hints.aiAddrLen := 0;
  hints.aiAddr := 0; hints.aiCanonName := 0; hints.aiNext := 0;

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
  netdb.freeAddrInfo(pres);
  IF tmp32 = 0 THEN
    Out.String("connect() succeeded."); Out.Ln;
    RETURN TRUE
  ELSE
    Out.String("connect() failed."); Out.Ln;
    RETURN FALSE
  END;


END Connect;

PROCEDURE Disconnect*(VAR fd: Socket);
VAR
  i : INTEGER;
BEGIN
i := Platform.Close(fd);
END Disconnect;

END Internet.
