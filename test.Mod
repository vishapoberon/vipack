MODULE test;

IMPORT IRC, Out, Strings := ooc2Strings;


PROCEDURE clbk(VAR in: ARRAY OF CHAR);
BEGIN
Out.String("callback procedure is running, youhoo!"); Out.Ln; 
Out.String("input:"); Out.Ln;
Out.String(in); Out.Ln;
Out.Ln;



END clbk;

PROCEDURE testBot;
VAR 
  inst: IRC.instance;
  channels : IRC.chnlist;
  b: BOOLEAN;
BEGIN
  inst.owner := "norayr_shimamoto";
  inst.user := "nakata_san";
  inst.nick := "oshima";
  inst.host := "irc.freenode.net";
  inst.port := "6667";
  inst.callback := clbk;
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
