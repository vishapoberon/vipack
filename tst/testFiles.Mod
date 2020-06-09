MODULE testFiles;
IMPORT Out, vpkFiles;

VAR
  f : vpkFiles.fileInfo;

PROCEDURE test(f: vpkFiles.fileInfo);
VAR
  b : BOOLEAN;
BEGIN
  Out.String(f.name); Out.Ln;
  IF vpkFiles.Exists(f) THEN
    Out.String("exists"); Out.Ln;
    IF vpkFiles.dir IN f.attr THEN Out.String("directory"); Out.Ln; END;
    IF vpkFiles.char IN f.attr THEN Out.String("char"); Out.Ln; END;
    IF vpkFiles.block IN f.attr THEN Out.String("block"); Out.Ln; END;
    IF vpkFiles.file IN f.attr THEN Out.String("file"); Out.Ln; END;
    IF vpkFiles.fifo IN f.attr THEN Out.String("fifo"); Out.Ln; END;
    IF vpkFiles.symlink IN f.attr THEN Out.String("symlink"); Out.Ln; END;
    IF vpkFiles.socket IN f.attr THEN Out.String("socket"); Out.Ln; END;
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

END testFiles.
