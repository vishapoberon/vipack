MODULE testFsHelper;
IMPORT Out, vpkFsHelper;

VAR
  dir : ARRAY 64 OF CHAR;
  f : vpkFsHelper.fileInfo;
  b : BOOLEAN;
BEGIN
  dir := "/home";
  f.name := "/home";

  IF vpkFsHelper.Exists(f) THEN
    Out.String("exists"); Out.Ln;
    IF vpkFsHelper.dir IN f.attr THEN Out.String("directory"); Out.Ln; END;
    IF vpkFsHelper.char IN f.attr THEN Out.String("char"); Out.Ln; END;
    IF vpkFsHelper.block IN f.attr THEN Out.String("block"); Out.Ln; END;
    IF vpkFsHelper.file IN f.attr THEN Out.String("file"); Out.Ln; END;
    IF vpkFsHelper.fifo IN f.attr THEN Out.String("fifo"); Out.Ln; END;
    IF vpkFsHelper.symlink IN f.attr THEN Out.String("symlink"); Out.Ln; END;
    IF vpkFsHelper.socket IN f.attr THEN Out.String("socket"); Out.Ln; END;
  ELSE
    Out.String("does not exist"); Out.Ln;
  END;

END testFsHelper.
