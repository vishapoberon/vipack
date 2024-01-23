MODULE vpkHttp;
IMPORT Strings, Internet, vpkLogger, Out;

TYPE
  PString = POINTER TO ARRAY OF CHAR;

VAR
  buff, buff2: PString;

PROCEDURE Empty*(VAR string: PString);
BEGIN
  NEW(string, 1);
  string[0] := 0X;
END Empty;

PROCEDURE getClean*(buff: ARRAY OF CHAR; VAR clean: PString);
VAR
  i: INTEGER;
  lineIsHeader, EOL, notFirstLine: BOOLEAN;
BEGIN
  i := 0;
  notFirstLine := FALSE;
  lineIsHeader := FALSE;
  EOL := FALSE;

  REPEAT
    IF EOL THEN
      lineIsHeader := FALSE;
      EOL := FALSE;
      notFirstLine := TRUE
    END;

    IF buff[i] = ":" THEN lineIsHeader := TRUE END;

    IF ((buff[i - 1] = 0DX) & (buff[i] = 0AX)) THEN EOL := TRUE END;

    INC(i);
  UNTIL (i + 2 > Strings.Length(buff)) OR (~lineIsHeader & EOL & notFirstLine);

  NEW(clean, Strings.Length(buff) - i + 1);
  Strings.Extract(buff, i, Strings.Length(buff), clean^);
END getClean;

PROCEDURE AppendEOLAndClean(buff: ARRAY OF CHAR; VAR buffClean: PString);
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

PROCEDURE addHeader(key, val: ARRAY OF CHAR; VAR buff: PString);
VAR
  header: PString;
  headerLength: LONGINT;
BEGIN
  headerLength := Strings.Length(key) + Strings.Length(val) + 2; (* 2 for ": " *)
  NEW(header, headerLength + 1); (* +1 for null terminator *)

  COPY(key, header^);
  Strings.Append(": ", header^);
  Strings.Append(val, header^);

  AppendEOLAndClean(header^, buff);
END addHeader;

PROCEDURE getHeader(buff, key: ARRAY OF CHAR; VAR val: PString);
VAR
  positionStart, valPositionStart, i: LONGINT;
BEGIN
  positionStart := Strings.Pos(key, buff, 0);
  valPositionStart := positionStart + Strings.Length(key) + 1;
  NEW(val, Strings.Length(buff) - valPositionStart + 1);
  i := 0;
  REPEAT
    val[i] := buff[valPositionStart + i];
    INC(i);
  UNTIL (ORD(val[i]) = 10) OR (i > Strings.Length(buff));
END getHeader;

PROCEDURE get*(host, port, path: ARRAY OF CHAR; VAR buff: PString);
VAR
  socket: Internet.Socket;
  connectionFlag: BOOLEAN;
  valueContentLength: REAL;
  send, valueContentLengthString: PString;
  sendClean: PString;
  httpTail: ARRAY 16 OF CHAR;
  tmpBuff: PString;
  sendLength: LONGINT;
BEGIN
  Empty(buff);
  httpTail := " HTTP/1.1";

  sendLength := Strings.Length(path) + Strings.Length(httpTail) + 4; (* 4 for "GET " *)
  NEW(send, sendLength);

  COPY("GET ", send^);
  Strings.Append(path, send^);
  Strings.Append(httpTail, send^);

  AppendEOLAndClean(send^, sendClean);
  connectionFlag := Internet.Write(socket, sendClean^);

  addHeader("HOST", host, sendClean);
  connectionFlag := Internet.Write(socket, sendClean^);

  addHeader("User-Agent", "oberon-http-client/1.0", sendClean);
  connectionFlag := Internet.Write(socket, sendClean^);

  addHeader("Accept", "*/*", sendClean);
  connectionFlag := Internet.Write(socket, sendClean^);

  AppendEOLAndClean("", sendClean);
  connectionFlag := Internet.Write(socket, sendClean^);

  REPEAT
    Empty(tmpBuff);
    connectionFlag := Internet.Read(socket, tmpBuff^);
    Strings.Append(tmpBuff^, buff^);
    getHeader(buff^, "Content-Length", valueContentLengthString);
    Strings.StrToReal(valueContentLengthString^, valueContentLength);
  UNTIL ~connectionFlag OR (Strings.Length(buff^) > valueContentLength);
  Internet.Disconnect(socket);
END get;


BEGIN
  (* Example usage of the get procedure *)
  (* get("example.com", "80", "/path", buff);
     getClean(buff^, buff2);
     vpkLogger.Log(buff2^); *)
END vpkHttp.
