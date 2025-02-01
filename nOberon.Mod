MODULE nOberon;

(* this version should not have dependency on graphics -- noch *)

  IMPORT Kernel, Texts := nTexts, Modules := nModules, nOut;

  TYPE
    ParList* = POINTER TO ParRec;
    ParRec* = RECORD
      (*
      vwr*: Viewers.Viewer;
      frame*: Display.Frame;
      *)
      text*: Texts.Text;
      pos*: LONGINT
    END;

  VAR
    Log*:        Texts.Text;
    Par*:        ParList;      (*actual parameters*)
    OptionChar*: CHAR;

    R: Texts.Reader;
    W: Texts.Writer;

  (*clocks*)

PROCEDURE GetClock* (VAR t, d: LONGINT);
BEGIN Kernel.GetClock(t, d)
END GetClock;
(*
PROCEDURE Time* (): LONGINT;
BEGIN RETURN Platform.Time()
END Time;
*)

  (*command interpretation*)

(** Execute an Oberon command. Name should be a string of the form
"M.P", where M is the module and P is the procedure of the command.
Par is the command parameter record; it will be assigned to Oberon.Par
so that the command can pick up its parameters. The new flag indicates
if the module M should be reloaded from disk (obly possible if M is a "top"
module, i.e. it has no clients. Res indicates success (res = 0) or failure (res # 0).
Modules.resMsg contains an explanation of what went wrong when res # 0. *)
PROCEDURE Call* (name: ARRAY OF CHAR; par: ParList; new: BOOLEAN; VAR res: INTEGER);
  VAR Mod: Modules.Module; P: Modules.Command; i, j: LONGINT;
BEGIN res := 1;
  i := 0; j := 0;
  WHILE name[j] # 0X DO
    IF name[j] = "." THEN i := j END;
    INC(j)
  END;
  IF i = 0 THEN i := j; name[j+1] := 0X END;
  name[i] := 0X;
  IF new THEN
    Modules.Free(name, FALSE);
    IF (Modules.res = 0) OR (Modules.res = 6) THEN Mod := Modules.ThisMod(name) END
ELSE
  Mod := Modules.ThisMod(name)
  END;
  IF Modules.res = 0 THEN
    INC(i); j := i;
    WHILE name[j] # 0X DO name[j - i] := name[j]; INC(j) END;
    name[j - i] := 0X;
    P := Modules.ThisCommand(Mod, name);
    IF Modules.res = 0 THEN
      Par := par;
      P; res := 0;
    ELSE res := Modules.res
    END
  ELSE res := Modules.res
  END
END Call;


PROCEDURE PopulateParams;
  VAR W: Texts.Writer; i: INTEGER; str: ARRAY 256 OF CHAR;
BEGIN
  Texts.OpenWriter(W);                  nOut.String("entered populateparams"); nOut.Ln;  nOut.String("noofargs "); nOut.Int(Kernel.NoOfArgs, 0); nOut.Ln;
  i := 2; (* skip program name *) (* was 1, but since this is called from shell, then 2 *)
  WHILE i < Kernel.NoOfArgs DO            nOut.String("while i < "); nOut.Ln;
    Kernel.GetArg(i, str); Texts.WriteString(W, str); Texts.Write(W, " ");                         nOut.String("arg="); nOut.String(str); nOut.Ln;
    INC(i)
  END;
  Texts.Append(Par^.text, W.buf);
END PopulateParams;

PROCEDURE GetSelection*(VAR text: Texts.Text; VAR beg, end, time: LONGINT);
BEGIN text := NIL; beg := 0; end := 0; time := 0
END GetSelection;

(* --- Notifier for echoing to the comsole all text appended to the log. --- *)
PROCEDURE LogNotifier(Log: Texts.Text; op: INTEGER; beg, end: LONGINT);
  VAR ch: CHAR;
BEGIN
  Texts.OpenReader(R, Log, beg);
  WHILE ~R.eot & (beg < end) DO
    Texts.Read(R, ch);
    IF ch = 0DX THEN nOut.Ln ELSE nOut.Char(ch) END;
    INC(beg)
  END
END LogNotifier;

BEGIN
   NEW(Par);
   NEW(Par.text);
   Par.pos := 0;
   OptionChar := '-';
   Texts.Open(Par.text, "");
   PopulateParams;
   NEW(Log);
   Texts.Open(Log, "");
   Log.notify := LogNotifier;
END nOberon.

