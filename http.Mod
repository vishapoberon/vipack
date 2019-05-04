MODULE http;
IMPORT Strings, Internet, Logger;
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

PROCEDURE get(host, path, port: ARRAY OF CHAR; VAR buff: ARRAY OF CHAR);
VAR 
    socket : Internet.Socket;
    connectionFlag: BOOLEAN;
    send: ARRAY MAXARRAYNUMBER OF CHAR;
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
    Logger.Log(sendClean^);
    connectionFlag := Internet.Write(socket, sendClean^);
    
    REPEAT 
      connectionFlag := Internet.Read(socket, tmpBuff);
      Strings.Append(tmpBuff, buff);
    UNTIL ~connectionFlag;
      
    Internet.Disconnect(socket);
END get;

BEGIN
  get("norayr.am", "/tmp/", "80", buff);
  Logger.Log(buff);
END http.