MODULE vpkFsHelper;
IMPORT SYSTEM;

CONST
  dir* = 0; char* = 1; block* = 2; file* = 3; fifo* = 4;
  symlink* = 5; socket* = 6;

TYPE
  fileInfo* = RECORD;
     name* : ARRAY 64 OF CHAR;
     attr- : SET
     END;

  Status = RECORD (* struct stat *)
    dev* : HUGEINT; (* dev_t 8 *)
    ino* : HUGEINT; (* ino 8 *)
    nlink* : HUGEINT;
    mode* : LONGINT;
    uid*, gid*: LONGINT;
    pad0* : LONGINT;
    rdev* : HUGEINT;
    size* : HUGEINT;
    blksize* : HUGEINT;
    blocks* : HUGEINT;
    atime* : HUGEINT;
    atimences* : HUGEINT;
    mtime* : HUGEINT;
    mtimensec* : HUGEINT;
    ctime* : HUGEINT;
    ctimensec* : HUGEINT;
    unused0*, unused1*, unused2*: HUGEINT;
    END;

PROCEDURE -Aincludesysstat '#include <sys/stat.h>';
PROCEDURE -Aincludesystypes '#include <sys/types.h>';

PROCEDURE -mkdir(VAR path: ARRAY OF CHAR): INTEGER
  "(int)mkdir(path, 0755)";

PROCEDURE mkDir*(VAR path: ARRAY OF CHAR): BOOLEAN;
VAR res: INTEGER;
BEGIN
   res := mkdir(path);
   IF res = 0 THEN RETURN TRUE ELSE RETURN FALSE END
END mkDir;

PROCEDURE -stat(VAR path : ARRAY OF CHAR; st: Status): INTEGER
"stat((const char*)path, (struct stat*)&st)";

PROCEDURE -isDir(mode: LONGINT): INTEGER
"S_ISDIR(mode)";

PROCEDURE -isChar(mode: LONGINT): INTEGER
"S_ISCHR(mode)";

PROCEDURE -isBlock(mode: LONGINT): INTEGER
"S_ISBLK(mode)";

PROCEDURE -isReg(mode: LONGINT): INTEGER
"S_ISREG(mode)";

PROCEDURE -isFIFO(mode: LONGINT): INTEGER
"S_ISFIFO(mode)";

PROCEDURE -isLnk(mode: LONGINT): INTEGER
"S_ISLNK(mode)";

PROCEDURE -isSock(mode: LONGINT): INTEGER
"S_ISSOCK(mode)";

PROCEDURE Exists*(VAR fl : fileInfo): BOOLEAN;
VAR
  i : INTEGER;
  st: Status;
BEGIN
  fl.attr := {};
  i := stat(fl.name, st);
  IF i < 0 THEN RETURN FALSE  END;
  IF i = 0 THEN (* file exists*) 
    i := isDir(st.mode);
    IF i # 0 THEN fl.attr := fl.attr + {dir} END;
    i := isChar(st.mode);
    IF i # 0 THEN fl.attr := fl.attr + {char} END;
    i := isBlock(st.mode);
    IF i # 0 THEN fl.attr := fl.attr + {block} END;
    i := isReg(st.mode);
    IF i # 0 THEN fl.attr := fl.attr + {file} END;
    i := isFIFO(st.mode);
    IF i # 0 THEN fl.attr := fl.attr + {fifo} END;
    i := isLnk(st.mode);
    IF i # 0 THEN fl.attr := fl.attr + {symlink} END;
    i := isSock(st.mode);
    IF i # 0 THEN fl.attr := fl.attr + {socket} END;
    RETURN TRUE
  END;
END Exists;


END vpkFsHelper.
