�^   Oberon20.Scn.Fnt  �  Syntax20.Scn.Fnt      C    -        P    ?      MODULE Shell;
IMPORT nOut, Kernel, nModules,   ooc2Strings;PROCEDURE extractModandProc(VAR cmd, mod, proc: ARRAY OF CHAR);VAR   pos: INTEGER;  found: BOOLEAN;  dot: ARRAY 2 OF CHAR;BEGIN  COPY(".", dot);   ooc2Strings.FindNext(dot, cmd, 0, found, pos);   IF found THEN       ooc2Strings.Extract(cmd, 0, pos,  mod);       ooc2Strings.Extract(cmd, pos+1, ooc2Strings.Length(cmd)-pos-1, proc);   ELSE       nOut.String("doesnt look like a command; module.procedure"); nOut.Ln; Kernel.Shutdown(1);   END;END extractModandProc;

PROCEDURE Run*; VAR   cmd: ARRAY 64 OF CHAR;    mod, proc: ARRAY 16 OF CHAR;    Command: Kernel.Proc;
BEGIN
  nOut.String("hey!");
  nOut.Ln;  nOut.Int(Kernel.NoOfArgs, 0); nOut.Ln;  IF Kernel.NoOfArgs > 1 THEN     Kernel.GetArg(1, cmd);     nOut.String("command: "); nOut.String(cmd); nOut.Ln;     extractModandProc(cmd, mod, proc);     nOut.String("module: "); nOut.String(mod); nOut.Ln;     nOut.String("procedure: "); nOut.String(proc); nOut.Ln; nOut.String("---"); nOut.Ln;     Command := nModules.ThisCommand(nModules.ThisMod(mod), proc);   nOut.String("executing command"); nOut.Ln;     Command;                                 nOut.String("command execution done"); nOut.Ln;       END;
  Kernel.Shutdown(0);

END Run;



END Shell.

