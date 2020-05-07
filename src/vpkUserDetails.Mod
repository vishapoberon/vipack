MODULE vpkUserDetails;
IMPORT Platform;

PROCEDURE GetUsername*(VAR str : ARRAY  OF CHAR):BOOLEAN;
BEGIN
 RETURN Platform.getEnv("USER", str);
END GetUsername;

END vpkUserDetails.
