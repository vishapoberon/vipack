MODULE vpkConf;
IMPORT Out, Files, Strings, Platform,
       vpkFsHelper, vpkSettings;

VAR
  conf, confDir : ARRAY 256 OF CHAR; 

PROCEDURE getHome(VAR path: ARRAY OF CHAR);
BEGIN
  IF ~(Platform.getEnv("HOME", path)) THEN
    Out.String("HOME variable is not found"); Out.Ln;
    HALT(1);
  END;
END getHome;

PROCEDURE mkConfContent(VAR path: ARRAY OF CHAR);
BEGIN
  Strings.Append('{"path" : "',  path);
  Strings.Append(vpkSettings.treeURL,   path);
  Strings.Append('"}, "type" : "git"}', path);
END mkConfContent;

PROCEDURE makeFile(VAR confFilePath: ARRAY OF CHAR; VAR f: Files.File; VAR r: Files.Rider);
BEGIN
f := Files.New(confFilePath);
Files.Set(r, f, 0);
END makeFile;

PROCEDURE writeInFile(VAR f: Files.File; r: Files.Rider; VAR text : ARRAY OF CHAR);
BEGIN
  Files.WriteBytes(r, text, Strings.Length(text));
END writeInFile;

PROCEDURE closeFile(VAR f: Files.File);
BEGIN
  Files.Register(f);
  Files.Close(f);
END closeFile;

PROCEDURE mkConfDirPath(home: ARRAY OF CHAR; VAR path: ARRAY OF CHAR);
BEGIN
  confDir := home;
  Strings.Append("/", path);
  Strings.Append(vpkSettings.vpkConfDir, path);
END mkConfDirPath;

PROCEDURE setConfPath;
VAR
  home: ARRAY 128 OF CHAR;
BEGIN
  getHome(home);
  mkConfDirPath(home, confDir);
  conf := confDir;
  Strings.Append("/", conf);
  Strings.Append(vpkSettings.vpkConfFile, conf);
END setConfPath;

PROCEDURE getConfPath*(VAR path: ARRAY OF CHAR);
BEGIN
  COPY(conf, path);
END getConfPath;

PROCEDURE getConfDir*(VAR path: ARRAY OF CHAR);
BEGIN
  COPY(confDir, path);
END getConfDir;

PROCEDURE configure*;
VAR
  content: ARRAY 256 OF CHAR;
  file : vpkFsHelper.fileInfo;
  fd: Files.File;
  rd: Files.Rider;
BEGIN
  file.name := conf;
  IF ~vpkFsHelper.Exists(file) THEN 
    (* Checking if ~/.vipack directory already exists *)
    file.name := confDir;
    IF ~vpkFsHelper.Exists(file) THEN (* exists!!! *)
      Out.String("Creating directory "); Out.String(confDir);Out.Ln;
      IF ~vpkFsHelper.mkDir(confDir) THEN
        Out.String("failed to create "); Out.String(confDir); Out.String(" directory"); Out.Ln;
        HALT(1);
      END;
    ELSE
      IF ~(vpkFsHelper.dir IN file.attr) THEN
        Out.String(confDir); Out.String(" exists, but is not a directory"); Out.Ln;
        HALT(1);
      END;
    END;
    (* create conf file *)
    Out.String("Creating the configuration file "); Out.String(conf);Out.Ln;
    content := "";
    makeFile(conf, fd, rd);
    mkConfContent(content);
    writeInFile(fd, rd, content);
    closeFile(fd);
 ELSE 
   Out.String("File already exists");Out.Ln;
 END;
END configure;

BEGIN
  setConfPath;
END vpkConf.
