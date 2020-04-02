MODULE vpkNetdb; (*noch 23.2.2017 / 14.4.2017*)

IMPORT SYSTEM;

CONST
    ipprotoIP* = 0;

    ipprotoICMP* = 1;

    ipprotoIGMP* = 2;

    ipprotoIPIP* = 4;

    ipprotoTCP* = 6;

    ipprotoEGP* = 8;

    ipprotoPUP* = 12;

    ipprotoUDP* = 17;

    ipprotoIDP* = 22;

    ipprotoTP* = 29;

    ipprotoDCCP* = 33;

    ipprotoIPV6* = 41;

    ipprotoRSVP* = 46;

    ipprotoGRE* = 47;

    ipprotoESP* = 50;

    ipprotoAH* = 51;

    ipprotoMTP* = 92;

    ipprotoBEETPH* = 94;

    ipprotoENCAP* = 98;

    ipprotoPIM* = 103;

    ipprotoCOMP* = 108;

    ipprotoSCTP* = 132;

    ipprotoUDPLITE* = 136;

    ipprotoMPLS* = 137;

    ipprotoRAW* = 255;

TYPE
  Int32* = LONGINT;
  Int64* = HUGEINT;

TYPE
   PaddrInfo* = POINTER [1] TO addrInfo;

   addrInfo* = RECORD
     aiFlags*: Int32;
     aiFamily*:Int32;
	 aiSockType*: Int32;
	 aiProtocol*: Int32;
	 aiAddrLen*:  Int32;
	 aiAddr*, aiCanonName*, aiNext*: SYSTEM.ADDRESS; (* pointers *)
   END;


PROCEDURE -getAddrInfo*(VAR node, service: ARRAY OF CHAR; hints: PaddrInfo; res: PaddrInfo): Int32
"getaddrinfo (node, service, hints, res)";

PROCEDURE -freeAddrInfo*( res: PaddrInfo)
"freeaddrinfo(res)";

END vpkNetdb.
