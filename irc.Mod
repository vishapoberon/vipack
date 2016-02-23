MODULE irc;
IMPORT sockets, netdb, Unix, Strings;

CONST strLen = 1024;

VAR
nick*, channel*, host*, port*, user*, command*, where*, message*, sep*, target*: ARRAY strLen OF CHAR;

PROCEDURE write(fd: Int32; VAR buf: ARRAY OF CHAR; len: LONGINT);
VAR
   l: LONGINT;
BEGIN
  Unix.Write(fd, buf, len);
END raw;

PROCEDURE connect;
VAR hints : netdb.addrInfo;
    res: netdb.PaddrInfo;
	tmp32 : netdb.Int32;
	conn : netdb.Int32;
	str0, str1: ARRAY 255 OF CHAR;
BEGIN
    hints.aiFamily := sockets.AfInet;
	hints.aiSockType := sockets.SockStream;
	hints.aiFlags := 0;
	hints.aiProtocol := 0;
	hints.aiAddrLen := 0;
	hints.aiAddr := 0; hints.aiCanonName := 0; hints.aiNext := 0;

	tmp32 := netdb.getAddrInfo(host, port, hints, res);
    conn := sockets.Socket(res^.aiFamily, res^.aiSockType, res^.aiProtocol);
	tmp32 := sockets.Connect(conn, res^.aiAddr, res^.aiAddrlen);

(* "USER test 0 0 :test\r\n" *)
(* "NICK test\r\n\000\060 :test\r\n"*)
    COPY("USER ", str0);
	Strings.Append(user, str0)
    Strings.Append(" 0 0 :", str0);
	Strings.Append(nick, str0);
	str1[0] := 0AX; str1[1] := 0DX; str1[2] := 0X;
	Strings.Append(str1, str0);
	write(conn, str0, Strings.Length(str0));
END connect;
