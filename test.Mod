MODULE test;

IMPORT IRC, Out;

VAR

owner, nick, host, port, channel: ARRAY 32 OF CHAR;

PROCEDURE testBot;
VAR b : BOOLEAN;
BEGIN
IF IRC.Connect(host, port) # FALSE THEN
  
  b := IRC.Auth("norayr", "norayr");

END;
END testBot;

BEGIN
owner := "norayr";
nick := "norayr";
host := "irc.freenode.net";
port := "6667";
channel := "#oberon";

testBot;

END test.
