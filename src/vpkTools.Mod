MODULE vpkTools;

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


END vpkTools.
