MODULE http;
IMPORT Internet, Out;
VAR
  buff: ARRAY 1000 OF CHAR;
PROCEDURE get(host, port: ARRAY OF CHAR; VAR buff: ARRAY OF CHAR);
VAR 
    socket : Internet.Socket;
    connectionFlag: BOOLEAN;
    send: ARRAY 7 OF CHAR;
BEGIN
    connectionFlag := Internet.Connect(host, port, socket);
    send[0] := "G";
    send[1] := "E";
    send[2] := "T";
    send[3] := 0DX;
    send[4] := 0AX;
    send[5] := " ";
    (* Somewhy it's ignoring the last byte *)

    connectionFlag := Internet.Write(socket, send);
    connectionFlag := Internet.Read(socket, buff);
    Internet.Disconnect(socket);
END get;

BEGIN
  get("voto.am", "80", buff);
  Out.String(buff);
  Out.Ln;
END http.