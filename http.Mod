MODULE http;
IMPORT Strings, Internet, Logger, Out;
CONST 
  MAXARRAYNUMBER = 10000;
  MAXARRAYNUMBEREXTENDED = 100000;
  
TYPE 
  PSTRING = POINTER TO ARRAY OF CHAR;

VAR
  buff, buff2: ARRAY MAXARRAYNUMBEREXTENDED OF CHAR;

PROCEDURE Empty *(VAR string: ARRAY OF CHAR);
VAR
    i : LONGINT;
BEGIN
    FOR i := 0 TO LEN(string) - 1 DO string[i] := 0X END;
    COPY("", string);
END Empty;

PROCEDURE getClean *(buff: ARRAY OF CHAR; VAR clean: ARRAY OF CHAR);
VAR
  i: INTEGER;
  newLine: ARRAY 2 OF CHAR;
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

  Strings.Extract(buff, i, Strings.Length(buff), clean);
END getClean;

PROCEDURE AppendEOLAndClean(buff: ARRAY OF CHAR; VAR buffClean: PSTRING);
VAR i: LONGINT;
BEGIN
  i := Strings.Length(buff);
  
  NEW(buffClean, i + 3);
  
  COPY(buff, buffClean^);

  buffClean[i] := 0DX;
  buffClean[i + 1] := 0AX;
  buffClean[i + 2] := " ";
END AppendEOLAndClean;

PROCEDURE addHeader(key, val: ARRAY OF CHAR; VAR buff: PSTRING);
VAR
  header: ARRAY MAXARRAYNUMBER OF CHAR;
BEGIN
  Empty(header);
  Strings.Append(key, header);
  Strings.Append(": ", header);
  Strings.Append(val, header);
  AppendEOLAndClean(header, buff);
END addHeader;

PROCEDURE getHeader(buff, key: ARRAY OF CHAR; VAR val: ARRAY OF CHAR);
VAR
  positionStart, valPositionStart, i: LONGINT;
BEGIN
  positionStart := Strings.Pos(key, buff, 0);
  valPositionStart := positionStart + Strings.Length(key) + 1;
  i := 0;
  REPEAT
    val[i] := buff[valPositionStart + i];
    INC(i);
  UNTIL (ORD(val[i]) = 10) (* 0DX number(newline)*) OR
  (i > Strings.Length(buff)); 
END getHeader;

PROCEDURE get *(host, port, path: ARRAY OF CHAR; VAR buff: ARRAY OF CHAR);
VAR 
    socket : Internet.Socket;
    connectionFlag: BOOLEAN;
    valueContentLength: REAL;
    send, valueContentLengthString: ARRAY MAXARRAYNUMBER OF CHAR;
    sendClean: PSTRING;
    httpTail: ARRAY 16 OF CHAR;
    endOfLine: ARRAY 3 OF CHAR;
    tmpBuff: ARRAY MAXARRAYNUMBER OF CHAR;
BEGIN
    Empty( buff);
    httpTail := " HTTP/1.1";
    
    connectionFlag := Internet.Connect(host, port, socket);
    
    send := "GET ";

    Strings.Append(path, send);
    Strings.Append(httpTail, send);


    AppendEOLAndClean(send, sendClean);
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
      Empty( tmpBuff);

      connectionFlag := Internet.Read(socket, tmpBuff);
      Strings.Append(tmpBuff, buff);
      getHeader(buff, "Content-Length", valueContentLengthString);
      Strings.StrToReal(valueContentLengthString, valueContentLength);
      (* Out.Real(valueContentLength, 6);
      Out.Ln;
      Logger.LogIntLn(Strings.Length(buff));
       *)
       Logger.Log(buff);
    UNTIL ~connectionFlag OR (Strings.Length(buff) > valueContentLength);
    Internet.Disconnect(socket);
END get;

BEGIN
  (* get("norayr.am", "/tmp/", "80", buff);
  getClean(buff, buff2);
  Logger.Log(buff2); *)
END http.