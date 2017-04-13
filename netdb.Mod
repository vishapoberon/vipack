MODULE netdb;

IMPORT SYSTEM;

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


PROCEDURE -getAddrInfo*(VAR node, service: ARRAY OF CHAR; VAR hints: addrInfo; res: PaddrInfo): Int32
"getaddrinfo (node, service, hints, res)";

PROCEDURE -freeAddrInfo*(VAR res: addrInfo)
"freeaddrinfo(res)";

END netdb.
