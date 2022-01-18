MODULE vpkEnv;
IMPORT Files, Platform, Strings, Out, vpkSettings, vpkFiles, StringList;

VAR
  conf, confDir : ARRAY 256 OF CHAR;

PROCEDURE getHome*(VAR path: ARRAY OF CHAR);
BEGIN
  IF ~(Platform.getEnv("HOME", path)) THEN
    Out.String("HOME variable is not found"); Out.Ln;
    HALT(1);
  END;
END getHome;

PROCEDURE getGraphName*(VAR grname: ARRAY OF CHAR);
BEGIN
  COPY (vpkSettings.graphName, grname);
END getGraphName;

PROCEDURE createIfNotThere*(VAR fileName: ARRAY OF CHAR);
BEGIN
    IF ~vpkFiles.ExistsByName(fileName) THEN
      IF ~vpkFiles.mkDir(fileName) THEN
        Out.String("failed to create directory "); Out.String(fileName); Out.Ln; HALT(1);
      END;
    END;

END createIfNotThere;

PROCEDURE getSrcRelPath*(VAR depName, path0: ARRAY OF CHAR): StringList.pstring;
VAR
  p: StringList.pstring;
  len: INTEGER;
BEGIN
  len := 9 + Strings.Length(depName) + Strings.Length(path0);
  (* 5 chars are ../, /, /, plus a couple of chars  *)
  NEW(p, len); 
  COPY("../", p^);
  Strings.Append(vpkSettings.vpkDepDir, p^);
  Strings.Append("/", p^);
  Strings.Append(depName, p^);
  Strings.Append("/", p^);
  Strings.Append(path0, p^);
  RETURN p;
END getSrcRelPath;

PROCEDURE mkConfDirPath(home: ARRAY OF CHAR; VAR path: ARRAY OF CHAR);
BEGIN
  confDir := home;
  Strings.Append("/", path);
  Strings.Append(vpkSettings.vpkConfDir, path);
END mkConfDirPath;

PROCEDURE mkdefPkgDirPath*(VAR name, path: ARRAY OF CHAR);
VAR
  home: ARRAY 128 OF CHAR;
BEGIN
  getHome(home);
  COPY(home, path);
  Strings.Append("/", path);
  Strings.Append(vpkSettings.vpkPkgDir, path);
  Strings.Append("/", path);
  createIfNotThere(path);
  Strings.Append(vpkSettings.vpkDepDir, path);
  Strings.Append("/", path);
  createIfNotThere(path);
  Strings.Append(name, path);
  createIfNotThere(path);
  Strings.Append("/", path);
END mkdefPkgDirPath;

PROCEDURE mkPkgDirPath*(VAR name, path: ARRAY OF CHAR);
BEGIN
  Strings.Append("/", path);
  createIfNotThere(path);
  Strings.Append(vpkSettings.vpkDepDir, path);
  Strings.Append("/", path);
  createIfNotThere(path);
  Strings.Append(name, path);
  createIfNotThere(path);
  Strings.Append("/", path);
END mkPkgDirPath;

PROCEDURE mkBldDirPath*(VAR prefix, builddir: ARRAY OF CHAR);
BEGIN
  COPY(prefix, builddir);
  createIfNotThere(builddir);
  Strings.Append("/", builddir);
  Strings.Append(vpkSettings.vpkBldDir, builddir);
  createIfNotThere(builddir);
  Strings.Append("/", builddir);
END mkBldDirPath;

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
    createIfNotThere(file.name);
END checkEnv;

BEGIN
  setConfFileName;

END vpkEnv.
