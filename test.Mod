MODULE test;

IMPORT irc;

VAR

owner, nick, serv, port, chan: ARRAY 32 OF CHAR;

PROCEDURE testBot;

BEGIN
irc.nick := nick;
irc.host := serv;
irc.port := port;
irc.channel := chan;
irc.user := owner;
irc.connect;
END testBot;

BEGIN
owner := "norayr";
nick := "norayr";
serv := "irc.freenode.net";
port := "6667";
chan := "#oberon";

testBot;

END test.
