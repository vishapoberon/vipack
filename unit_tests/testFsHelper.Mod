MODULE testFsHelper;
IMPORT Out, vpkFsHelper;

VAR
  f : vpkFsHelper.fileInfo;

PROCEDURE test(f: vpkFsHelper.fileInfo);
VAR
  b : BOOLEAN;
BEGIN
  Out.String(f.name); Out.Ln;
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
  Out.Ln;
END test;

BEGIN
  f.name := "/aosenth";
  test(f);
  f.name := "/dev/nvme0n1";
  test(f);
  f.name := "/home";
  test(f);
  f.name := "/etc/fstab";
  test(f);
  f.name := "/usr/src/linux";
  test(f);
  f.name := "/dev/video0";
  test(f);
  f.name := "/tmp/fifo";
  test(f);

END testFsHelper.
