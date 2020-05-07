MODULE types; (*noch 23.2.2017 / 13.4.2017*)
IMPORT SYS := SYSTEM;


TYPE
     intarr64 = ARRAY 8 OF SYS.BYTE; (* to emulate int16 on x86_64; -- noch *)
     intarr32 = ARRAY 4 OF SYS.BYTE;
     intarr16 = ARRAY 2 OF SYS.BYTE;
     Int16* = INTEGER; (* INTEGER on 32 bit platform *)
     Int32* = LONGINT;
     Int64* = HUGEINT;
     String* = ARRAY 256 OF CHAR;
     
   PROCEDURE HugeintToInt16*(in: HUGEINT; VAR out: Int16);
   VAR
    int64 : intarr64; 
    int16 : intarr16;
   BEGIN
    int64 := SYS.VAL(intarr64, in);
    int16[0] := int64[0];
    int16[1] := int64[1];
    out := SYS.VAL(Int16, int16)
   END HugeintToInt16;

   PROCEDURE LongintToInt16*(int: LONGINT; VAR int16: Int16);
   BEGIN
      int16 := SYS.VAL(Int16, int)
   END LongintToInt16;

   PROCEDURE htons*(in: Int16; VAR out : Int16);
   VAR
     tmpin, tmpout : intarr16;
   BEGIN
      tmpin := SYS.VAL(intarr16, in);
      tmpout := SYS.VAL(intarr16, out);
      tmpout[0] := tmpin[1];
      tmpout[1] := tmpin[0];
      out := SYS.VAL(Int16, tmpout)
   END htons;

END types.
