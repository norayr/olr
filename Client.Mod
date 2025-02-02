�#   Syntax20.Scn.Fnt  M   M  MODULE Client;

IMPORT Internet, Out, Linux0;
PROCEDURE Connect*;
VAR
  sock: Internet.Socket;
  addr: Internet.Address;
  buf: ARRAY 256 OF CHAR;
  bytesSent, bytesReceived: LONGINT;  res: BOOLEAN;  port: INTEGER;

BEGIN  port := 8080;
  (* Set up the server address *)
  Internet.SetAddress(Internet.AfInet, Internet.InAddrAny, port, addr);

  (* Create a socket *)
  sock := Internet.OpenSocket(Internet.AfInet, Internet.SockStream, 0);
  IF sock < 0 THEN
    Out.String("Failed to create socket."); Out.Ln;
    RETURN
  END;  Out.String("Socket created: "); Out.Int(sock, 0); Out.Ln;

  (* Connect to the server *)
  IF ~Internet.Connect(sock, addr) THEN
    Out.String("Failed to connect to server."); Out.Ln;
    res := Internet.Close(sock);
    RETURN
  END;

  Out.String("Connected to server."); Out.Ln;

  (* Prepare the message *)
  COPY("Hello from Client!", buf);

  (* Send the message *)
  bytesSent := Internet.Send(sock, buf, LEN(buf), 0);
  IF bytesSent <= 0 THEN
    Out.String("Failed to send data."); Out.Ln;    Out.String("bytesSent is "); Out.Int(bytesSent, 0); Out.Ln;
    res := Internet.Close(sock);
    RETURN
  ELSE
    Out.String("Sent: "); Out.String(buf); Out.Ln;
  END;

  (* Clear the buffer *)
  buf := "";

  (* Receive the response *)
  bytesReceived := Internet.Receive(sock, buf, LEN(buf), 0);
  IF bytesReceived > 0 THEN
    Out.String("Received: "); Out.String(buf); Out.Ln;
  ELSE
    Out.String("Failed to receive data."); Out.Ln;
  END;

  (* Close the socket *)
  res := Internet.Close(sock);
  Out.String("Connection closed."); Out.Ln;END Connect;
END Client.

