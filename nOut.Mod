�#   Oberon10.Scn.Fnt       MODULE nOut;

IMPORT Linux0, SYSTEM;


PROCEDURE Char*(c: CHAR);
VAR i: LONGINT;
BEGIN
  IF c=0DX THEN c:= 0AX END;
  i:= Linux0.Write0( 1, SYSTEM.ADR(c), 1);
END Char;

(** WriteString - Write a string *)

PROCEDURE String*( s: ARRAY OF CHAR);
VAR k, l, err: LONGINT;
BEGIN
  l:=0;
  WHILE (l<LEN(s)) & (s[l]# 0X) DO INC( l) END;
  err:= Linux0.Write0( 1, SYSTEM.ADR(s), l);
END String;

(** WriteLn - Skip to the next line on trace output *)

PROCEDURE Ln*;
(*
VAR s: ARRAY 3 OF CHAR;
BEGIN
  s[0] := 0DX;  s[1] := 0AX;  s[2] := 0X;  WriteString( s);
*)
BEGIN Char( 0AX);
END Ln;

(** WriteInt - Write "x" as a decimal number.  "w" is the field width. *)

PROCEDURE Int*(x, w: LONGINT);
VAR
  i: LONGINT;
  x0: LONGINT;
  a: ARRAY 12 OF CHAR;
  s: ARRAY 2 OF CHAR;
BEGIN
  IF x < 0 THEN
    IF x = MIN(LONGINT) THEN
     String( "-2147483648");
      RETURN
    ELSE
      DEC(w); x0 := -x
    END
  ELSE
    x0 := x
  END;
  i := 0;
  REPEAT
    a[i] := CHR(x0 MOD 10 + 30H); x0 := x0 DIV 10; INC(i)
  UNTIL x0 = 0;
  s[0] := " ";  s[1] := 0X;
  WHILE w > i DO String( s); DEC(w) END;
  s[0] := "-";
  IF x < 0 THEN String( s) END;
  REPEAT DEC(i); s[0] := a[i]; String( s) UNTIL i = 0
END Int;

(** WriteHex - Write "x" as a hexadecimal number.
  The absolute value of "w" is the field width.  If "w" is negative, two
  hex digits are printed (x MOD 100H), otherwise 8 digits are printed. *)

PROCEDURE Hex*(x, w: LONGINT);
VAR
  buf: ARRAY 10 OF CHAR;
  err, i, j: LONGINT;
  c: CHAR;
BEGIN
  c:=" ";
  IF w >= 0 THEN j := 8 ELSE j := 2; w := -w END;
  FOR i := j+1 TO w DO Char( c) END;
  FOR i := j-1 TO 0 BY -1 DO
    buf[i] := CHR(x MOD 10H + 48);
    IF buf[i] > "9" THEN
      buf[i] := CHR(ORD(buf[i]) - 48 + 65 - 10)
    END;
    x := x DIV 10H
  END;
  buf[j] := 0X;
  String( buf);
END Hex;

END nOut.
