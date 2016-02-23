MODULE netdb;

IMPORT SYSTEM;

TYPE
  Int32* = INTEGER;
  Int64* = LONGINT;

TYPE
   PaddrInfo = POINTER [1] TO addrInfo;

   addrInfo* = RECORD
     aiFlags*: Int32;
     aiFamily*:Int32;
	 aiSockType*: Int32;
	 aiProtocol*: Int32;
	 aiAddrLen*:  Int32;
	 aiAddr*, aiCanonName*, aiNext*: LONGINT; (* pointers *)
   END;


PROCEDURE getAddrInfo*(VAR node, service: ARRAY OF CHAR; VAR hints: addrInfo; res: LONGINT): Int32
"getaddrinfo (node, service, hints, res)";

PROCEDURE freeAddrInfo*(VAR res: addrInfo)
"freeaddrinfo(res)";

END netdb.
