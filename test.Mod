MODULE test;

IMPORT IRC, Out, Strings := ooc2Strings;

VAR

owner, user, nick, host, port, channel: ARRAY 32 OF CHAR;

PROCEDURE testBot;
VAR 
  b: BOOLEAN;
  channels : IRC.chnlist;
BEGIN
  NEW(channels, 1);
  channels[0] := channel;
  IRC.setChannelList(channels);

  IF IRC.Connect(host, port) # FALSE THEN
    b := IRC.Auth(user, nick, owner);
    IRC.Loop;
  END;
END testBot;

BEGIN
owner := "norayr_tanakian";
user := "norayr_tanakian";
nick := "vocbot";
host := "irc.freenode.net";
port := "6667";
channel := "#oberon";

testBot;

END test.
