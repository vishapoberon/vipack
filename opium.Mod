MODULE opium;
IMPORT
    Args,
    Logger,
    PackageFileParser,
    Strings;
CONST
    helpText = "HEEEELP";
    ArrayMaxNumber = 500;
VAR
    command: ARRAY ArrayMaxNumber OF CHAR;

PROCEDURE help();
BEGIN
    Logger.Log(helpText);
END help;

PROCEDURE parseArgs(VAR argument: ARRAY OF CHAR);
BEGIN
    COPY("", argument);
    IF Args.argc > 1 THEN Args.Get(1, argument) END;

END parseArgs;

BEGIN
    parseArgs(command);

    IF Strings.Match(command, "") THEN 
        help;
    ELSIF Strings.Match(command, "install") THEN 
        PackageFileParser.install();
    END;
END opium.
