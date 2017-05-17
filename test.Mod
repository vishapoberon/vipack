MODULE test;

IMPORT IRC, Out, Strings := ooc2Strings;


PROCEDURE onMessage(VAR msg : ARRAY OF CHAR);
BEGIN
   Out.String("callback procedure is running, youhoo!"); Out.Ln; 
   Out.String("input:"); Out.Ln;
   Out.String(msg); Out.String("|"); Out.Ln;
   Out.Ln;
END onMessage;

PROCEDURE onPrivateMessage(VAR msg, user, ident, host: ARRAY OF CHAR);
BEGIN
  Out.String("*** private message ***"); Out.Ln;
  Out.String("message: '"); Out.String(msg); Out.Char("'"); Out.Ln;
  Out.String("user: '"); Out.String(user); Out.Char("'"); Out.Ln;
  Out.String("ident: '"); Out.String(ident); Out.Char("'"); Out.Ln;
  Out.String("host: '"); Out.String(host); Out.Char("'"); Out.Ln;
  Out.String("*** that's it ***"); Out.Ln;
END onPrivateMessage;

PROCEDURE onPublicMessage(VAR msg, user, ident, rcpt, host: ARRAY OF CHAR);
BEGIN
  Out.String("*** public message ***"); Out.Ln;
  Out.String("message: '"); Out.String(msg); Out.Char("'"); Out.Ln;
  Out.String("user: '"); Out.String(user); Out.Char("'"); Out.Ln;
  Out.String("ident: '"); Out.String(ident); Out.Char("'"); Out.Ln;
  Out.String("recipient: '"); Out.String(rcpt); Out.Char("'"); Out.Ln;
  Out.String("host: '"); Out.String(host); Out.Char("'"); Out.Ln;
  Out.String("*** that's it ***"); Out.Ln;
END onPublicMessage;

PROCEDURE onPublicMessageWithMention(VAR msg, user, ident, rcpt, host: ARRAY OF CHAR);
BEGIN
  Out.String("*** public message, bot name mentioned ***"); Out.Ln;
  Out.String("message: '"); Out.String(msg); Out.Char("'"); Out.Ln;
  Out.String("user: '"); Out.String(user); Out.Char("'"); Out.Ln;
  Out.String("ident: '"); Out.String(ident); Out.Char("'"); Out.Ln;
  Out.String("recipient: '"); Out.String(rcpt); Out.Char("'"); Out.Ln;
  Out.String("host: '"); Out.String(host); Out.Char("'"); Out.Ln;
  Out.String("*** that's it ***"); Out.Ln;
END onPublicMessageWithMention;


PROCEDURE testBot;
VAR 
  inst: IRC.instance;
  channels : IRC.chnlist;
  b: BOOLEAN;
BEGIN
  inst.owner := "norayr_tanakian";
  inst.user := "norayr_tanakian";
  inst.nick := "vocbot";
  inst.host := "irc.freenode.net";
  inst.port := "6667";
  inst.callbackSimple := onMessage;
  inst.callbackPrivate := onPrivateMessage;
  inst.callbackPublic := onPublicMessage;
  inst.callbackPublicMention := onPublicMessageWithMention;



  NEW(channels, 1);
  channels[0] := "#oberon";
  IRC.setChannelList(inst, channels);

  IF IRC.Connect(inst) # FALSE THEN
    b := IRC.Auth(inst);
    IRC.Loop(inst);
  END;
END testBot;

BEGIN

testBot;

END test.
