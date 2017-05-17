MODULE test;

IMPORT IRC, Out, Strings := ooc2Strings;


PROCEDURE clbk(VAR msg : ARRAY OF CHAR);
BEGIN
Out.String("callback procedure is running, youhoo!"); Out.Ln; 
Out.String("input:"); Out.Ln;
Out.String(msg); Out.String("|"); Out.Ln;
Out.Ln;
END clbk;

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
  inst.callbackSimple := clbk;



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
