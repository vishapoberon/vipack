MODULE test;

IMPORT IRC, Out;

VAR

owner, user, nick, host, port, channel: ARRAY 32 OF CHAR;

PROCEDURE testBot;
VAR b : BOOLEAN;
BEGIN
IF IRC.Connect(host, port) # FALSE THEN
  
  b := IRC.Auth(user, nick, owner);

END;
END testBot;

BEGIN
owner := "norayr_tanakian";
user := "norayr";
nick := "arnet";
host := "irc.freenode.net";
port := "6667";
channel := "#oberon";

testBot;

END test.
