MODULE vpkHttp;
IMPORT IntStr := oocIntStr, Strings, Internet, vpkLogger, Out, strTypes, strUtils;
CONST
  defHeaderLength = 1024;
     defUserAgent = "oberon-http-client/1.0";
   defHttpVersion = "HTTP/1.1";
        defGetStr = "GET";
       defHostStr = "HOST";
         defUAStr = "User-Agent";
     defAcceptStr = "Accept";
 defEverythingStr = "*/*";

              hdrDate = "Date";
            hdrServer = "Server";
      hdrLastModified = "Last-Modified";
              hdrETag = "ETag";
      hdrAcceptRanges = "Accept-Ranges";
     hdrContentLength = "Content-Length";
              hdrVary = "Vary";
       hdrContentType = "Content-Type";
  hdrTransferEncoding = "Transfer-Encoding";
        hdrConnection = "keey-alive";
      hdrCacheControl = "Cache-Control";
           hdrExpires = "Expires";
          hdrLocation = "Location";
          hdrReportTo = "Report-To";
               hdrNEL = "NEL";
             hdrCFRAY = "CF-RAY";


TYPE

  httpClient = POINTER TO httpClientDesc;

  httpClientDesc = RECORD
    host-, port-, path- : strTypes.pstring;
                 socket : Internet.Socket;
         connectionFlag : BOOLEAN;
             userAgent- : strTypes.pstring;
               version- : strTypes.pstring;
                    eol : ARRAY 2 OF CHAR;
                   null : ARRAY 1 OF CHAR;
             reqHeader- : POINTER TO ARRAY 5 OF strTypes.pstring;
          rspnPstrings- : strTypes.pstrings;
         rspnFirstLine- : strTypes.pstring;
              rspnDate- : strTypes.pstring;
            rspnServer- : strTypes.pstring;
      rspnLastModified- : strTypes.pstring;
              rspnETag- : strTypes.pstring;
      rspnAcceptRanges- : strTypes.pstring;
     rspnContentLength- : LONGINT;
              rspnVary- : strTypes.pstring;
       rspnContentType- : strTypes.pstring;
  rspnTransferEncoding- : strTypes.pstring;
        rspnConnection- : strTypes.pstring;
      rspnCacheControl- : strTypes.pstring;
           rspnExpires- : strTypes.pstring;
          rspnLocation- : strTypes.pstring;
          rspnReportTo- : strTypes.pstring;
               rspnNEL- : strTypes.pstring;
             rspnCFRAY- : strTypes.pstring;

                Create* : PROCEDURE(host, port, path: ARRAY OF CHAR): httpClient;
                   Get* : PROCEDURE(VAR http: httpClient): strTypes.pstring;
          setUserAgent* : PROCEDURE(VAR http: httpClient; ua: ARRAY OF CHAR);
            clearState* : PROCEDURE(VAR http: httpClient);
  END;

VAR (* these variables are only for testing *)
  http: httpClient;
  answer, answer2: strTypes.pstring;

PROCEDURE Empty(VAR string: strTypes.pstring);
VAR i : LONGINT;
BEGIN
  (*NEW(string, 512);
  string[0] := 0X;*)
  i := 0;
  REPEAT
    string[i] := 0X;
    INC(i)
  UNTIL i = LEN(string^) -1;
END Empty;

PROCEDURE clearstate(VAR http: httpClient);
BEGIN
  http^.rspnPstrings          := NIL;
  http^.rspnFirstLine         := NIL;
  http^.rspnDate              := NIL;
  http^.rspnServer            := NIL;
  http^.rspnLastModified      := NIL;
  http^.rspnETag              := NIL;
  http^.rspnAcceptRanges      := NIL;
  http^.rspnContentLength     := 0;
  http^.rspnVary              := NIL;
  http^.rspnContentType       := NIL;
  http^.rspnTransferEncoding  := NIL;
  http^.rspnConnection        := NIL;
  http^.rspnCacheControl      := NIL;
  http^.rspnExpires           := NIL;
  http^.rspnLocation          := NIL;
  http^.rspnReportTo          := NIL;
  http^.rspnNEL               := NIL;
  http^.rspnCFRAY             := NIL;

END clearstate;

PROCEDURE getClean(buff: ARRAY OF CHAR; VAR clean: strTypes.pstring);
VAR
  i: INTEGER;
  lineIsHeader, EOL, notFirstLine: BOOLEAN;
BEGIN
  i := 0;
  notFirstLine := FALSE;
  lineIsHeader := FALSE;
  EOL := FALSE;
                Out.String("entered repeat in getClean"); Out.Ln;
  REPEAT
    IF EOL THEN
      lineIsHeader := FALSE;
      EOL := FALSE;
      notFirstLine := TRUE
    END;

    IF buff[i] = ":" THEN lineIsHeader := TRUE; Out.String("found ':'"); Out.Ln; END;

    IF ((buff[i - 1] = 0DX) & (buff[i] = 0AX)) THEN EOL := TRUE END;

    INC(i);
    Out.String("i is now "); Out.Int(i, 0); Out.Ln;
  UNTIL (i + 2 > Strings.Length(buff)) OR (~lineIsHeader & EOL & notFirstLine);

    Out.String("after until i is now "); Out.Int(i, 0); Out.Ln;
                Out.String("exited repeat in getClean"); Out.Ln;
  NEW(clean, Strings.Length(buff)  + 2);
                Out.String("starting extract"); Out.Ln;
  Strings.Extract(buff, i, Strings.Length(buff), clean^);
                Out.String("finished extract"); Out.Ln;
END getClean;

PROCEDURE AppendEOLAndClean(buff: ARRAY OF CHAR; VAR buffClean: strTypes.pstring);
VAR
  i: LONGINT;
BEGIN
  i := Strings.Length(buff);
  NEW(buffClean, i + 3);

  COPY(buff, buffClean^);
  buffClean[i] := 0DX;
  buffClean[i + 1] := 0AX;
  buffClean[i + 2] := 0X;
END AppendEOLAndClean;

PROCEDURE getHeader(VAR buff: ARRAY OF CHAR; key: ARRAY OF CHAR): strTypes.pstring;
VAR
  positionStart, valPositionStart, i: LONGINT;
  val: strTypes.pstring;
BEGIN
  positionStart := Strings.Pos(key, buff, 0);

  IF positionStart = -1 THEN
    RETURN NIL;
  END;

  valPositionStart := positionStart + Strings.Length(key) + 1;
  NEW(val, 8);
  (*Empty(val);*)
  i := 0;
  REPEAT
    val[i] := buff[valPositionStart + i];
    IF (val[i] = 0AX) OR (val[i] = 0DX) THEN
      val[i] := 0X
    ELSE
      val[i+1] := 0X
    END;
    INC(i);
    (*
    Out.String("length is '"); Out.String(val^); Out.String("'"); Out.Ln;
    Out.String("current character is '"); Out.Int(ORD(val[i-1]), 0); Out.String("'"); Out.Ln;
    *)
 UNTIL (val[i-1] = 0X) OR (i = Strings.Length(buff)-1);
 RETURN val;
END getHeader;

PROCEDURE readHeader(VAR http: httpClient):strTypes.pstring;
VAR
  valueContentLength: LONGINT;
  valueContentLengthString: strTypes.pstring;
  header, buff: strTypes.pstring;
  headerBool : BOOLEAN;
  res: SHORTINT;
  i: INTEGER;
  n: INTEGER;
BEGIN
  NEW(header, defHeaderLength);
  Empty(header);
  NEW(buff, 2);
  i := 0; headerBool := FALSE;
  REPEAT
    http^.connectionFlag := Internet.Read(http^.socket, buff^);
    header[i] := buff[0];
    (*      Out.String("got character: "); Out.Int(ORD(buff[0]), 0); Out.Ln;*)
    IF (header[i] = 0DX) THEN
      http^.connectionFlag := Internet.Read(http^.socket, buff^);
      INC(i); header[i] := buff[0];
               (*  Out.String("got character: "); Out.Int(ORD(buff[0]), 0); Out.Ln;*)
      IF (header[i] = 0AX) THEN
        http^.connectionFlag := Internet.Read(http^.socket, buff^);
        INC(i); header[i] := buff^[0];
        IF header[i] = 0DX THEN
          http^.connectionFlag := Internet.Read(http^.socket, buff^);
          INC(i); header[i] := buff^[0];
          IF header[i] = 0AX THEN headerBool := TRUE END;
        END;
      END;
    END;
    INC(i);
    header[i] := 0X;
(*    Out.String("header is '"); Out.String(header^); Out.Char("'"); Out.Ln;*)
  UNTIL headerBool;
  RETURN header
END readHeader;

PROCEDURE processHeader(VAR http: httpClient; VAR hdr: ARRAY OF CHAR);
VAR
  len, i, j: INTEGER;
  key: ARRAY 64 OF CHAR;
  val: ARRAY 512 OF CHAR;
  res: SHORTINT;
  isLengthFound: BOOLEAN;
BEGIN
  isLengthFound := FALSE;
  len := Strings.Length(hdr);
  Out.String("header length is "); Out.Int(len, 0); Out.Ln;

  (* getting string like 'HTTP/1.1 200 OK', hopefully *)
  http^.rspnPstrings := strUtils.string2pstrings(hdr);
strUtils.string2pstring(http^.rspnPstrings^[0]^, http^.rspnFirstLine);
           Out.String("first line: '"); Out.String(http^.rspnFirstLine^);
           Out.Char("'"); Out.Ln;
  i := 1;
  REPEAT
          Out.Int(i, 0); Out.String(": ");
          Out.String(http^.rspnPstrings^[i]^); Out.Ln;
    j := strUtils.Pos(':', http^.rspnPstrings^[i]^, 0);
    Strings.Extract(http^.rspnPstrings^[i]^, 0, j, key);
          Out.String("key: '"); Out.String(key); Out.Char("'"); Out.Ln;
    strUtils.getTillEOL(http^.rspnPstrings^[i]^, j+1, val);
          Out.String("val: '"); Out.String(val); Out.Char("'"); Out.Ln;
    IF key = hdrDate THEN strUtils.string2pstring(val, http^.rspnDate) END;
    IF key = hdrServer THEN strUtils.string2pstring(val, http^.rspnServer) END;
    IF key = hdrLastModified THEN strUtils.string2pstring(val, http^.rspnLastModified) END;
    IF key = hdrETag THEN strUtils.string2pstring(val, http^.rspnETag) END;
    IF key = hdrAcceptRanges THEN strUtils.string2pstring(val, http^.rspnAcceptRanges) END;
    IF key = hdrContentLength THEN
      isLengthFound := TRUE;
      IntStr.StrToInt(val, http^.rspnContentLength, res);
      IF res # IntStr.strAllRight THEN
        Out.String("not number"); Out.Ln; HALT(1)
      ELSE
        Out.String("got content length: "); Out.Int(http^.rspnContentLength, 0); Out.Ln
      END;
    END;

    IF key = hdrVary THEN strUtils.string2pstring(val, http^.rspnVary) END;
    IF key = hdrContentType THEN strUtils.string2pstring(val, http^.rspnContentType) END;
    IF key = hdrTransferEncoding THEN strUtils.string2pstring(val, http^.rspnTransferEncoding) END;
    IF key = hdrConnection THEN strUtils.string2pstring(val, http^.rspnConnection) END;
    IF key = hdrCacheControl THEN strUtils.string2pstring(val, http^.rspnCacheControl) END;
    IF key = hdrExpires THEN strUtils.string2pstring(val, http^.rspnExpires) END;
    IF key = hdrLocation THEN strUtils.string2pstring(val, http^.rspnLocation) END;
    IF key = hdrReportTo THEN strUtils.string2pstring(val, http^.rspnReportTo) END;
    IF key = hdrNEL THEN strUtils.string2pstring(val, http^.rspnNEL) END;
    IF key = hdrCFRAY THEN strUtils.string2pstring(val, http^.rspnCFRAY) END;

    INC(i)
  UNTIL i = LEN(http^.rspnPstrings^)-1;
  IF ~isLengthFound THEN http^.rspnContentLength := 64000 END
END processHeader;

PROCEDURE get*(VAR http: httpClient): strTypes.pstring;
VAR
  header, tmpBuff, buff: strTypes.pstring;
  firstRead: BOOLEAN;
  readFailure: BOOLEAN; eof: BOOLEAN;
  readThisTime, readAll: LONGINT;
BEGIN
  firstRead := TRUE;
  readThisTime := 0; readAll := 0;
  http^.clearState(http);
  (* Establish connection *)
     Out.String("connecting to:"); Out.Ln;
     Out.String("host: '"); Out.String(http^.host^); Out.Char("'"); Out.Ln;
     Out.String("port: '"); Out.String(http^.port^); Out.Char("'"); Out.Ln;
     Out.String("path: '"); Out.String(http^.path^); Out.Char("'"); Out.Ln;
  http^.connectionFlag := Internet.Connect(http^.host^, http^.port^, http^.socket);
  IF ~http^.connectionFlag THEN
    Out.String("Connection failed");
    Out.Ln;
    HALT(5)
  END;
  REPEAT
        Out.String("sending '"); Out.String(http^.reqHeader[0]^); Out.Char("'"); Out.Ln;
    http^.connectionFlag := Internet.Write(http^.socket, http^.reqHeader[0]^);
        Out.String("sending '"); Out.String(http^.reqHeader[1]^); Out.Char("'"); Out.Ln;
    http^.connectionFlag := Internet.Write(http^.socket, http^.reqHeader[1]^);
        Out.String("sending '"); Out.String(http^.reqHeader[2]^); Out.Char("'"); Out.Ln;
    http^.connectionFlag := Internet.Write(http^.socket, http^.reqHeader[2]^);
        Out.String("sending '"); Out.String(http^.reqHeader[3]^); Out.Char("'"); Out.Ln;
    http^.connectionFlag := Internet.Write(http^.socket, http^.reqHeader[3]^);
        Out.String("sending '"); Out.String(http^.reqHeader[4]^); Out.Char("'"); Out.Ln;
    http^.connectionFlag := Internet.Write(http^.socket, http^.reqHeader[4]^);

    header := readHeader(http);
    processHeader(http, header^);
    NEW(tmpBuff, http^.rspnContentLength);
    readFailure := FALSE; eof := FALSE;
    REPEAT
      Out.String("repeat"); Out.Ln;
      Empty(tmpBuff);
      http^.connectionFlag := Internet.ReadBuf(http^.socket, tmpBuff^, readThisTime);
      IF readThisTime < 0 THEN readFailure := TRUE; Out.String("read failure"); Out.Ln END;
      IF readThisTime = 0 THEN eof := TRUE; Out.String("eol=true"); Out.Ln END;
      readAll := readAll + readThisTime;
      Out.String("readThisTime="); Out.Int(readThisTime, 0); Out.Ln;
      Out.String("readAll="); Out.Int(readAll, 0); Out.Ln;
      strUtils.append(tmpBuff, buff);
      Out.String("-----------------------------"); Out.Ln;
      Out.String("tmpBuff is: '"); Out.String(tmpBuff^); Out.Char("'"); Out.Ln;
      Out.String("-----------------------------"); Out.Ln;
      Out.String("buff is: '"); Out.String(buff^); Out.Char("'"); Out.Ln;
      Out.String("-----------------------------"); Out.Ln;
      Out.String("reached until"); Out.Ln;
      IF http^.connectionFlag THEN Out.String("true") ELSE Out.String("false") END; Out.Ln;
      Out.String("length tmpBuff "); Out.Int(Strings.Length(tmpBuff^), 0); Out.Ln;
      Out.String("len tmpBuff "); Out.Int(LEN(tmpBuff^), 0); Out.Ln;
      Out.String("length buff "); Out.Int(Strings.Length(buff^), 0); Out.Ln;
      Out.String("len buff "); Out.Int(LEN(buff^), 0); Out.Ln;
      Out.String("content length "); Out.Int(http^.rspnContentLength, 0); Out.Ln;
      Out.String("readThisTime="); Out.Int(readThisTime, 0); Out.Ln;
      Out.String("readAll="); Out.Int(readAll, 0); Out.Ln;
    UNTIL (Strings.Length(buff^) >= http^.rspnContentLength) OR eof OR readFailure OR ~http^.connectionFlag OR (http^.rspnContentLength = 0);
  UNTIL eof OR (readAll >= http^.rspnContentLength);
    Out.String("until exited"); Out.Ln;
  Internet.Disconnect(http^.socket);
  Out.String("disconnected"); Out.Ln;
  RETURN buff
END get;

PROCEDURE nextHeaderLine(key, val: ARRAY OF CHAR): strTypes.pstring;
VAR
  header: strTypes.pstring;
  headerLength, tmp: LONGINT;
BEGIN
  headerLength := Strings.Length(key)
          + Strings.Length(val) + 2 (* 2 for ": " *)
          + 3; (* for eol: 0DX, 0AX, 0X *)
  NEW(header, headerLength);
    Out.String("header is now '"); Out.String(header^); Out.Char("'"); Out.Ln;
  COPY(key, header^);
    Out.String("header is now '"); Out.String(header^); Out.Char("'"); Out.Ln;
  Strings.Append(": ", header^);
    Out.String("header is now '"); Out.String(header^); Out.Char("'"); Out.Ln;
  Strings.Append(val, header^);

    Out.String("header is now '"); Out.String(header^); Out.Char("'"); Out.Ln;

  tmp := Strings.Length(header^);
  header^[tmp] := 0DX;
  header^[tmp+1] := 0AX;
  header^[tmp+2] := 0X;
    Out.String("header is now '"); Out.String(header^); Out.Char("'"); Out.Ln;
  RETURN header
END nextHeaderLine;

PROCEDURE formReqHeader(VAR http: httpClient);
VAR
  pstr: strTypes.pstring;
  len, tmp: INTEGER;
BEGIN
  NEW(http^.reqHeader);
  len := Strings.Length(http^.path^) + 1 (* space *) + Strings.Length(http^.version^) + 4 + 3 (* "GET " *);
  NEW(http^.reqHeader[0], len);
  COPY(defGetStr, http^.reqHeader[0]^);
  Strings.Append(" ",           http^.reqHeader[0]^);
  Strings.Append(http^.path^,    http^.reqHeader[0]^);
  Strings.Append(" ",           http^.reqHeader[0]^);
  Strings.Append(http^.version^, http^.reqHeader[0]^);
  tmp := Strings.Length(http^.reqHeader[0]^);
  http^.reqHeader[0]^[tmp] := 0DX;
  http^.reqHeader[0]^[tmp+1] := 0AX;
  http^.reqHeader[0]^[tmp+2] := 0X;
  (*
  Strings.Append(http^.eol,     http^.reqHeader[0]^);
  Strings.Append(http^.null,    http^.reqHeader[0]^);
*)
  http^.reqHeader[1] := nextHeaderLine(defHostStr, http^.host^);

  http^.reqHeader[2] := nextHeaderLine(defUAStr, http^.userAgent^);

  http^.reqHeader[3] := nextHeaderLine(defAcceptStr, defEverythingStr);

  NEW(http^.reqHeader[4], 3);
  COPY(http^.eol, http^.reqHeader[4]^);
  Strings.Append(http^.null, http^.reqHeader[4]^);
END formReqHeader;

PROCEDURE setuseragent*(VAR http: httpClient; ua: ARRAY OF CHAR);
BEGIN
  strUtils.string2pstring(ua, http^.userAgent)
END setuseragent;

PROCEDURE Create*(host, port, path: ARRAY OF CHAR): httpClient;
VAR
  http: httpClient;
BEGIN
  NEW(http);
  http^.eol[0] := 0DX; http^.eol[1] := 0AX; http^.null[0] := 0X;
  strUtils.string2pstring(host, http^.host);
  strUtils.string2pstring(port, http^.port);
  strUtils.string2pstring(path, http^.path);
  strUtils.string2pstring(defUserAgent, http^.userAgent);
  strUtils.string2pstring(defHttpVersion, http^.version);

  http^.Get := get;
  http^.setUserAgent := setuseragent;
  http^.clearState := clearstate;
  formReqHeader(http);

  http^.rspnPstrings          := NIL;
  http^.rspnFirstLine         := NIL;
  http^.rspnDate              := NIL;
  http^.rspnServer            := NIL;
  http^.rspnLastModified      := NIL;
  http^.rspnETag              := NIL;
  http^.rspnAcceptRanges      := NIL;
  http^.rspnContentLength     := 0;
  http^.rspnVary              := NIL;
  http^.rspnContentType       := NIL;
  http^.rspnTransferEncoding  := NIL;
  http^.rspnConnection        := NIL;
  http^.rspnCacheControl      := NIL;
  http^.rspnExpires           := NIL;
  http^.rspnLocation          := NIL;
  http^.rspnReportTo          := NIL;
  http^.rspnNEL               := NIL;
  http^.rspnCFRAY             := NIL;

  RETURN http
END Create;

BEGIN
  (* Example usage of the get procedure *)
   http := Create("norayr.am", "80", "/test.html");
   answer := http.Get(http);
   (*getClean(answer^, answer2);*)
   vpkLogger.Log(answer^);
END vpkHttp.
