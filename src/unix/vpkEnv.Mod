MODULE vpkEnv;
IMPORT Files, Platform, Strings, Out, vpkSettings, vpkFiles;

VAR
  conf, confDir : ARRAY 256 OF CHAR;

PROCEDURE getHome*(VAR path: ARRAY OF CHAR);
BEGIN
  IF ~(Platform.getEnv("HOME", path)) THEN
    Out.String("HOME variable is not found"); Out.Ln;
    HALT(1);
  END;
END getHome;

PROCEDURE mkConfDirPath(home: ARRAY OF CHAR; VAR path: ARRAY OF CHAR);
BEGIN
  confDir := home;
  Strings.Append("/", path);
  Strings.Append(vpkSettings.vpkConfDir, path);
END mkConfDirPath;

PROCEDURE setConfFileName;
VAR
  home: ARRAY 128 OF CHAR;
BEGIN
  getHome(home);
  mkConfDirPath(home, confDir);
  conf := confDir;
  Strings.Append("/", conf);
  Strings.Append(vpkSettings.vpkConfFile, conf);
END setConfFileName;

PROCEDURE getConfPath(VAR path: ARRAY OF CHAR);
BEGIN
  COPY(conf, path);
END getConfPath;

PROCEDURE getConfDir*(VAR path: ARRAY OF CHAR);
BEGIN
  COPY(confDir, path);
END getConfDir;

PROCEDURE getConfFile*(): Files.File;
VAR f: Files.File;
BEGIN
  f := Files.Old(conf);
  IF f = NIL THEN
    f := Files.New(conf)
  END;
  RETURN f;
END getConfFile;

PROCEDURE checkConfig*(): BOOLEAN;
VAR
  file : vpkFiles.fileInfo;
BEGIN
  file.name := conf;
  RETURN vpkFiles.Exists(file);
END checkConfig;

PROCEDURE getTreeDir*(VAR path: ARRAY OF CHAR);
BEGIN
  COPY(confDir, path);
  Strings.Append("/", path);
  Strings.Append(vpkSettings.vpkTreeDir, path);
END getTreeDir;

PROCEDURE checkEnv*;
VAR
 file : vpkFiles.fileInfo;
 tmp  : ARRAY 256 OF CHAR;
BEGIN
  file.name := conf;
  IF ~vpkFiles.Exists(file) THEN
    (* Checking if ~/.vipack directory already exists *)
    file.name := confDir;
    IF ~vpkFiles.Exists(file) THEN (* exists!!! *)
      Out.String("Creating directory "); Out.String(confDir);Out.Ln;
      IF ~vpkFiles.mkDir(confDir) THEN
        Out.String("failed to create "); Out.String(confDir); Out.String(" directory"); Out.Ln;
        HALT(1);
      END;
    ELSE
      IF ~(vpkFiles.dir IN file.attr) THEN
        Out.String(confDir); Out.String(" exists, but is not a directory"); Out.Ln;
        HALT(1);
      END;
    END;
  END;  
    tmp := confDir;
    Strings.Append('/', tmp);
    Strings.Append(vpkSettings.vpkTreeDir, tmp);
    file.name := tmp;
    IF ~vpkFiles.Exists(file) THEN
      IF ~vpkFiles.mkDir(file.name) THEN
        Out.String("failed to create tree dir "); Out.String(tmp); Out.Ln; HALT(1);
      END;
    END;
END checkEnv;

BEGIN
  setConfFileName;

END vpkEnv.
