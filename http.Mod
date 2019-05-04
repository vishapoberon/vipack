MODULE http;
IMPORT Strings, Internet, Logger, Out;
CONST 
  MAXARRAYNUMBER = 10000;
  MAXARRAYNUMBEREXTENDED = 1000000;
  
TYPE 
  PSTRING = POINTER TO ARRAY OF CHAR;

VAR
  buff: ARRAY MAXARRAYNUMBEREXTENDED OF CHAR;

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
  COPY("", header);
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
  valPositionStart := positionStart + Strings.Length(key);
  i := 0;
  REPEAT
    val[i] := buff[valPositionStart + i];
    INC(i);
  UNTIL val[i]; (* TODO: check value char number *)
END getHeader;

PROCEDURE get(host, path, port: ARRAY OF CHAR; VAR buff: ARRAY OF CHAR);
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
    COPY("", buff);
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
      connectionFlag := Internet.Read(socket, tmpBuff);
      Strings.Append(tmpBuff, buff);
      getHeader(buff, "Content-Length", valueContentLengthString);
      Strings.StrToReal(valueContentLengthString, valueContentLength);
      Out.Real(valueContentLength, 20);
      Out.Ln;
    UNTIL ~connectionFlag OR (Strings.Length(buff) > valueContentLength);
    Internet.Disconnect(socket);
END get;

BEGIN
  get("norayr.am", "/tmp/", "80", buff);
  Logger.Log(buff);
END http.