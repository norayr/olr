�#   Syntax20.Scn.Fnt  �   �  MODULE Internet;

IMPORT Linux0, SYSTEM, Out;

TYPE
  Socket* = LONGINT;
  Address* = POINTER TO AddressDesc;
  AddressDesc = RECORD
    family*: INTEGER;
    port*: INTEGER;
    addr*: LONGINT;
    zero: ARRAY 8 OF CHAR; (* Padding for sockaddr_in structure *)
  END;

CONST
  AfInet* = 2; (* IPv4 *)
  SockStream* = 1; (* TCP *)
  InAddrAny* = 0; (* Bind to all interfaces *)

PROCEDURE htons(hostShort: INTEGER): INTEGER;
BEGIN
  RETURN  SYSTEM.VAL(INTEGER, (hostShort MOD 100H) * 100H + (hostShort DIV 100H))
END htons;

(* Create a new socket *)

PROCEDURE OpenSocket*(domain, type, protocol: LONGINT): Socket;
BEGIN
  RETURN Linux0.Socket0(domain, type, protocol)
END OpenSocket;

(* Bind the socket to an address and port *)
PROCEDURE Bind*(s: Socket; VAR addr: Address): BOOLEAN;
BEGIN
  RETURN Linux0.Bind0(s, SYSTEM.ADR(addr^), SIZE(AddressDesc)) = 0
END Bind;

(* Listen for incoming connections *)
PROCEDURE Listen*(s: Socket; backlog: LONGINT): BOOLEAN;
BEGIN
  RETURN Linux0.Listen0(s, backlog) = 0
END Listen;

(* Accept a new connection *)
PROCEDURE Accept*(s: Socket; VAR clientAddr: Address): Socket;
VAR
  addrLen: LONGINT;
BEGIN
  addrLen := SIZE(AddressDesc);
  RETURN Linux0.Accept0(s, SYSTEM.ADR(clientAddr^), SYSTEM.ADR(addrLen))
END Accept;

(* Connect to a remote address *)
PROCEDURE Connect*(s: Socket; VAR addr: Address): BOOLEAN;
BEGIN
  RETURN Linux0.Connect0(s, SYSTEM.ADR(addr^), SIZE(AddressDesc)) = 0
END Connect;

(* Send data through a socket *)
PROCEDURE Send*(s: Socket; buf: ARRAY OF CHAR; len, flags: LONGINT): LONGINT;VAR res: LONGINT;
BEGIN  Out.String("buf[0]="); Out.Char(buf[0]); Out.Ln;  Out.String("buf[1]="); Out.Char(buf[1]); Out.Ln;  Out.String("buf[2]="); Out.Char(buf[2]); Out.Ln;  IF s < 0 THEN    Out.String("Invalid socket descriptor.."); Out.Ln;    RETURN -1  END;  Out.String("Sending data... Socket: "); Out.Int(s, 0); Out.Ln;  Out.String("Buffer address: "); Out.Hex(SYSTEM.VAL(LONGINT, SYSTEM.ADR(buf[0]))); Out.Ln;  Out.String("Length: "); Out.Int(len, 0); Out.Ln;
  res := Linux0.Send0(s, SYSTEM.ADR(buf[0]), len, flags);  Out.String("Internet.Send0 result: "); Out.Int(res, 0); Out.Ln;  RETURN res
END Send;

(* Receive data from a socket *)
PROCEDURE Receive*(s: Socket; VAR buf: ARRAY OF CHAR; len, flags: LONGINT): LONGINT;
BEGIN
  RETURN Linux0.Recv0(s, SYSTEM.ADR(buf[0]), len, flags)
END Receive;

(* Close a socket *)
PROCEDURE Close*(s: Socket): BOOLEAN;
BEGIN
  RETURN Linux0.Close0(s) = 0
END Close;

(* Helper to set up an Address record for IPv4 *)
PROCEDURE SetAddress*(family: INTEGER; addr: LONGINT; port: INTEGER; VAR a: Address);VAR test: LONGINT;
BEGIN
  NEW(a);
  a.family := family;  a.port := htons(port);  Out.String("port "); Out.Int(port, 0); Out.String(" converted to "); Out.Int(a.port, 0); Out.Ln;  test := SYSTEM.VAL(LONGINT, a.port); Out.String("as longing: "); Out.Int(test, 0); Out.Ln;
  a.addr := addr;
  a.zero := "";
END SetAddress;

END Internet.

