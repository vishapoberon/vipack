MODULE vpkFiles;
IMPORT SYSTEM;

CONST
  dir* = 0; char* = 1; block* = 2; file* = 3; fifo* = 4;
  symlink* = 5; socket* = 6;

TYPE
  fileInfo* = RECORD;
     name* : ARRAY 256 OF CHAR;
     attr- : SET
     END;

(* https://github.com/vishaps/voc/blob/4bebc891a4d0d1184d74134908bdc1a91e3ad5be/src/lib/system/freebsd/clang/x86_64/Unix.Mod
from output of cpp /usr/include/sys/stat.h
struct stat {
 __dev_t st_dev; 
 ino_t st_ino;
 mode_t st_mode;
 nlink_t st_nlink;
 uid_t st_uid;
 gid_t st_gid;
 __dev_t st_rdev;
 struct timespec st_atim;
 struct timespec st_mtim;
 struct timespec st_ctim;
 off_t st_size;
 blkcnt_t st_blocks;
 blksize_t st_blksize;
 fflags_t st_flags;
 __uint32_t st_gen;
 __int32_t st_lspare;
 struct timespec st_birthtim;
# 148 "/usr/include/sys/stat.h"
 unsigned int :(8 / 2) * (16 - (int)sizeof(struct timespec));
 unsigned int :(8 / 2) * (16 - (int)sizeof(struct timespec));
};
sizes on freebsd 64 bit
short int 2
int 4
long 8
long int 8
size_t 8
dev_t 4
ino_t 4
mode_t 2
nlink_t 2
uid_t 4
gid_t 4
off_t 8
blksize_t 4
blkcnt_t 8
time_t 8
fflags_t  4
__uint32_t  4
__int32_t  4
*)

(* this was old info. now it's like this:

size of stat is 224
size of s.st_dev is 8
size of s.st_ino is 8
size of s.st_nlink is 8
size of s.st_mode is 2
size of s.st_padding0 is 2
size of s.st_uid is 4
size of s.st_gid is 4
size of s.st_padding1 is 4
size of s.rdev is 8
size of s.st_atim is 16
size of s.st_mtim is 16
size of s.st_ctim is 16
size of s.st_birthtim is 16
size of s.st_size is 8
size of s.st_blocks is 8
size of s.st_blksize is 4
size of s.st_flags is 4
size of s.st_gen is 8
size of s.st_spare is 80
*)

  Status*  =  RECORD (* struct stat *)
    dev*   : HUGEINT; (* dev_t 8 *)
    ino*   : HUGEINT; (* ino_t 8 *)
    nlink* : HUGEINT; (* nlink_t 8 *)
    mode*: INTEGER;   (* mode_t  4 *)
    padding0: INTEGER;
    uid*, gid*: LONGINT; (* uid_t, gid_t 4 *)
    padding1: LONGINT;
    rdev*: HUGEINT; (* dev_t 8 *)
    atime* : HUGEINT; atimences* : HUGEINT; 
    mtime* : HUGEINT; mtimences* : HUGEINT; (* struct timespec 16 *)
    ctime* : HUGEINT; ctimences* : HUGEINT; (* struct timespec 16 *)
    birthtime* : HUGEINT; birthtimences* : HUGEINT; (* struct timespec 16 *)
    size*: HUGEINT; (* off_t 8 *) 
    blocks* : HUGEINT;
    blksize* : LONGINT;
    flags* : LONGINT;
    gen* : HUGEINT;
    lspare* : ARRAY 10 OF HUGEINT;
  END ;

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

PROCEDURE ExistsByName*(VAR fileName : ARRAY OF CHAR): BOOLEAN;
VAR
  i : INTEGER;
  st: Status;
  fl: fileInfo;
BEGIN
  fl.attr := {};
  COPY(fileName, fl.name);
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
END ExistsByName;


END vpkFiles.
