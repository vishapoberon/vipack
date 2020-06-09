MODULE testJsonParser;
IMPORT vpkJsonParser, Out;

VAR
    jsonRecord: vpkJsonParser.JsonTypePointer;
    testValue: ARRAY 128 OF CHAR;
    keyFound: BOOLEAN;

BEGIN
  jsonRecord := vpkJsonParser.Create("{'foo': 'bar', 'test': 'test1', 'test2': {'sub': 'dub'}}");

  keyFound := jsonRecord.GetTerminal(jsonRecord, "foo", testValue);

  IF keyFound THEN
    Out.String('found KEY');
    Out.String(testValue); Out.Ln;
  ELSE
    Out.String('Value for the Key is not found'); Out.Ln;
  END;
    keyFound := jsonRecord.GetTerminal(jsonRecord, "test2.sub", testValue);
  IF keyFound THEN
    Out.String('found KEY');
    Out.String(testValue); Out.Ln;
  ELSE
    Out.String('Value for the Key is not found'); Out.Ln;
  END;

END testJsonParser.
