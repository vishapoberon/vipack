MODULE http;
IMPORT Internet, Out;
PROCEDURE get(host, port: ARRAY OF CHAR, VAR buff: ARRAY 1000 OF CHAR);
VAR 
    socket : Internet.Socket;
    connected: BOOLEAN;
    send: ARRAY 7 OF CHAR;
BEGIN
    connected := Internet.Connect(host, port, socket);
    send[0] := "G";
    send[1] := "E";
    send[2] := "T";
    send[3] := 0DX;
    send[4] := 0AX;
    send[5] := " ";
    (* Somewhy it's ignoring the last byte *)

    connected := Internet.Write(socket, send);
    connected := Internet.Read(socket, buff);
    Internet.Disconnect(socket);

END get;
VAR
  buff: ARRAY 1000 OF CHAR
BEGIN
  get("google.am", "80", buff);
  Out.String(buff);
  Out.Ln;
END http.