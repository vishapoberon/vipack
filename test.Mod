MODULE test;

IMPORT IRC, Out, Strings := ooc2Strings;

VAR

owner, user, nick, host, port, channel: ARRAY 32 OF CHAR;

PROCEDURE testBot;
VAR 
  b, b2: BOOLEAN;
  patternFound : BOOLEAN;
  patternPos: INTEGER;
  str, str2, str3: ARRAY 512 OF CHAR;
BEGIN
IF IRC.Connect(host, port) # FALSE THEN
  
  b := IRC.Auth(user, nick, owner);
  REPEAT
    b := IRC.Receive(str);
    Strings.Extract(str, 0, 4, str2);
    IF Strings.Equal(str2, IRC.ping) THEN 
      (*b := IRC.Send(IRC.pong);*)
      str[1] := 'O'; (* replace "PING" by "PONG" *)
      b2 := IRC.Send(str);
    ELSIF str[0] = ':' THEN
      Out.String("':' found"); Out.Ln;
      Strings.FindNext(IRC.zzo, str, 0, patternFound, patternPos);
      IF patternFound THEN
        Out.String("001 found"); Out.Ln;
        COPY ("MODE ", str3);
        Strings.Append(nick, str3);
        Strings.Append(" +B", str3);
        Strings.Append(IRC.eol, str3);
        Strings.Append(0X, str3);
        b2 := IRC.Send(str3);
        COPY("JOIN ", str3);
        Strings.Append("#oberon", str3);
        Strings.Append(IRC.eol, str3);
        Strings.Append(0X, str3);
        b2 := IRC.Send(str3);
      END;
    END;
  UNTIL ~b;
END;
END testBot;

BEGIN
owner := "norayr_tanakian";
user := "norayr_tanakian";
nick := "arnet_am";
host := "irc.freenode.net";
port := "6667";
channel := "#oberon";

testBot;

END test.
