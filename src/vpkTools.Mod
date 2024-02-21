MODULE vpkTools;
IMPORT Strings, strUtils;


PROCEDURE extractDomainFromUrl*(VAR url: ARRAY OF CHAR; VAR domain: ARRAY OF CHAR);
VAR
  start, i, j: INTEGER;
BEGIN
  start := 0;
  (* Skip protocol to find the start of the domain *)
  WHILE (start < LEN(url) - 1) & (url[start] # 0X) & ((url[start] # ':') OR (url[start+1] # '/')) DO
    INC(start);
  END;

  (* Skip the "://" part to actually reach the start of the domain *)
  INC(start, 3);  (* Assuming we stopped at ':', so we skip "://" *)

  i := start;
  (* Now 'start' is at the beginning of the domain, find the end of the domain *)
  WHILE (i < LEN(url)) & (url[i] # 0X) & (url[i] # '/') DO
    INC(i);
  END;

  (* Copy domain from url *)
  j := 0;
  WHILE (start < i) & (j < LEN(domain) - 1) DO
    domain[j] := url[start];
    INC(j); INC(start);
  END;
  domain[j] := 0X;  (* Ensure the domain string is null-terminated *)
END extractDomainFromUrl;

PROCEDURE extractPathFromUrl*(VAR url: ARRAY OF CHAR; VAR path: ARRAY OF CHAR);
VAR
  i, j, domainEnd: INTEGER;
  foundDomain: BOOLEAN;
BEGIN
  i := 0; foundDomain := FALSE;
  WHILE ~foundDomain & (i < LEN(url) - 1) & (url[i] # 0X) DO
    IF (url[i] = ':') & (url[i + 1] = '/') & (url[i + 2] = '/') THEN
      foundDomain := TRUE;
      i := i + 3;
    END;
    INC(i);
  END;

  IF foundDomain THEN
    domainEnd := i;
    WHILE (domainEnd < LEN(url)) & (url[domainEnd] # 0X) & (url[domainEnd] # '/') DO
      INC(domainEnd);
    END;

    j := 0;
    WHILE (domainEnd < LEN(url)) & (url[domainEnd] # 0X) & (j < LEN(path) - 1) DO
      path[j] := url[domainEnd];
      INC(j); INC(domainEnd);
    END;
    path[j] := 0X;
  ELSE
    path[0] := 0X; (* if no domain found *)
  END;
END extractPathFromUrl;

PROCEDURE extractFilenameFromUrl*(VAR url: ARRAY OF CHAR; VAR result: ARRAY OF CHAR);
VAR
  lastSlashPos: INTEGER;
BEGIN
  (* Find the position of the last '/' character in the URL *)
  lastSlashPos := -1;
  lastSlashPos := strUtils.Rpos(url, '/');

  (* Extract the part of the URL after the last '/' to get the filename *)
  IF lastSlashPos >= 0 THEN
    Strings.Extract(url, lastSlashPos + 1, Strings.Length(url) - lastSlashPos - 1, result);
  ELSE
    (* If '/' is not found, assume the entire URL is a filename *)
    COPY(url, result);
  END;
END extractFilenameFromUrl;


END vpkTools.
