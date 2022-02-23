// this file was used on freebsd to create struct stat mapping
// in the src/unix/vpkFreeBSDFiles.Mod binding.
#include "sys/stat.h"
#include "stdio.h"

int main()
{
struct stat s;
printf ("size of stat is %i\n", sizeof(s));

printf ("size of s.st_dev is %i\n", sizeof(s.st_dev));
printf ("size of s.st_ino is %i\n", sizeof(s.st_ino));
printf ("size of s.st_nlink is %i\n", sizeof(s.st_nlink));
printf ("size of s.st_mode is %i\n", sizeof(s.st_mode));
printf ("size of s.st_padding0 is %i\n", sizeof(s.st_padding0));
printf ("size of s.st_uid is %i\n", sizeof(s.st_uid));
printf ("size of s.st_gid is %i\n", sizeof(s.st_gid));
printf ("size of s.st_padding1 is %i\n", sizeof(s.st_padding1));
printf ("size of s.rdev is %i\n", sizeof(s.st_rdev));
printf ("size of s.st_atim is %i\n", sizeof(s.st_atim));
printf ("size of s.st_mtim is %i\n", sizeof(s.st_mtim));
printf ("size of s.st_ctim is %i\n", sizeof(s.st_ctim));
printf ("size of s.st_birthtim is %i\n", sizeof(s.st_birthtim));
printf ("size of s.st_size is %i\n", sizeof(s.st_size));
printf ("size of s.st_blocks is %i\n", sizeof(s.st_blocks));
printf ("size of s.st_blksize is %i\n", sizeof(s.st_blksize));
printf ("size of s.st_flags is %i\n", sizeof(s.st_flags));
printf ("size of s.st_gen is %i\n", sizeof(s.st_gen));
printf ("size of s.st_spare is %i\n", sizeof(s.st_spare));

return 0;

}
