//---------------------------------------------------------------------------
//   Author: Chuck Kelly,
//           Monroe County Community College
//           http://www.monroeccc.edu/ckelly
//---------------------------------------------------------------------------

#include "net.h"

// Network
DWORD        dwLength = 4096;           // Length of send and receive buffers
WSADATA      wsd;
SOCKET       s;
char         *recvbuf;
char         *sendbuf;
int          ret = 0;
DWORD        dwSenderSize = 0;
SOCKADDR_IN  remote, local;
bool         netInitialized = false;
char         mode = UNINITIALIZED;
int          type = UNCONNECTED;

//---------------------------------------------------------------------------
// Initialize network
// protocol = UDP or TCP

int __fastcall netInit(int port, int protocol)
{
  unsigned long ul = 1;
  int           nRet;
  int status;

  if(netInitialized)            // if network currently initialized
    netCloseSockets();             // close current network and start over

  mode = UNINITIALIZED;

  status = WSAStartup(0x0101, &wsd);
  if (status != 0)
    return ( (status << 16) + NET_INIT_FAILED);

  switch (protocol)
  {
    case UDP:     // UDP
    // Create UDP socket and bind it to a local interface and port
    s = socket(AF_INET, SOCK_DGRAM, 0);
    if (s == INVALID_SOCKET) {
      status = WSAGetLastError();          // get detailed error
      return ( (status << 16) + NET_INVALID_SOCKET);
    }
    type = UDP;
    break;
    case TCP:     // TCP
    // Create TCP socket and bind it to a local interface and port
    s = socket(AF_INET, SOCK_STREAM, IPPROTO_TCP);
    if (s == INVALID_SOCKET) {
      status = WSAGetLastError();          // get detailed error
      return ( (status << 16) + NET_INVALID_SOCKET);
    }
    type = UNCONNECTED_TCP;
    break;
    default:    // Invalid type
      return (NET_INIT_FAILED);
  }

  // put socket in non-blocking mode
  nRet = ioctlsocket(s, FIONBIO, (unsigned long *) &ul);
  if (nRet == SOCKET_ERROR) {
    status = WSAGetLastError();         // get detailed error
    return ( (status << 16) + NET_INVALID_SOCKET);
  }

  // set local port
  local.sin_family = AF_INET;
  local.sin_port = htons((u_short)port);        // port number

  // set remote port
  remote.sin_family = AF_INET;
  remote.sin_port = htons((u_short)port);       // port number

  // Allocate the receive buffer
  recvbuf = (char *)GlobalAlloc(GMEM_FIXED, dwLength);
  if (!recvbuf)
    return NET_INIT_FAILED;

  // Allocate the send buffer
  sendbuf = (char *)GlobalAlloc(GMEM_FIXED, dwLength);
  if (!sendbuf)
    return NET_INIT_FAILED;

  netInitialized = true;
  return NET_OK;
}

//------------------------------------------------------------------------
// Setup network for use as server
int __fastcall netCreateServer(int port, int protocol) {

  int status;

  // ----- Initialize network stuff -----
  status = netInit(port, protocol);
  if (status != NET_OK)
    return status;

  local.sin_addr.s_addr = htonl(INADDR_ANY);    // listen on all addresses

  // bind socket
  if (bind(s, (SOCKADDR *)&local, sizeof(local)) == SOCKET_ERROR)
  {
    status = WSAGetLastError();          // get detailed error
    if (status == WSAEADDRINUSE)
      return NET_ADDR_IN_USE;
    return ((status << 16) + NET_BIND_FAILED);
  }
  mode = SERVER;

  return NET_OK;
}

//------------------------------------------------------------------------
// Setup network for use as a client
int __fastcall netCreateClient(char *server, int port, int protocol) {

  int status;
  char serverIP[16] = "255.255.255.255";
  char localIP[16] =  "255.255.255.255";
  hostent* host;

  // ----- Initialize network stuff -----
  status = netInit(port, protocol);
  if (status != NET_OK)
    return status;

  // if server does not contain a dotted quad IP address nnn.nnn.nnn.nnn
  if ((remote.sin_addr.s_addr = inet_addr(server)) == INADDR_NONE) {
    host = gethostbyname(server);
    if(host == NULL)                    // if gethostbyname failed
      return NET_DOMAIN_NOT_FOUND;

    // set serverIP to IP address as string "aaa.bbb.ccc.ddd"
    sprintf(serverIP, "%d.%d.%d.%d",
          (unsigned char)host->h_addr_list[0][0],
          (unsigned char)host->h_addr_list[0][1],
          (unsigned char)host->h_addr_list[0][2],
          (unsigned char)host->h_addr_list[0][3]);
    remote.sin_addr.s_addr = inet_addr(serverIP);
    strncpy(server, inet_ntoa(remote.sin_addr), 16);  // return IP of server
  }

  // set local IP address
  netLocalIP(localIP);          // get local IP
  local.sin_addr.s_addr = inet_addr(localIP);   // local IP

  mode = CLIENT;
  return NET_OK;
}

//-------------------------------------------------------------------------
// Send data to the recipient
//
int __fastcall netSendData(char *data, int &size, char *remoteIP) {
  int status;

  if (mode == SERVER)
    remote.sin_addr.s_addr = inet_addr(remoteIP);

  if(mode == SERVER && type == UNCONNECTED_TCP) {
    listen(s,1);
    SOCKET tempSock;
    tempSock = accept(s,NULL,NULL);
    if (tempSock == INVALID_SOCKET) {
      status = WSAGetLastError();
      if ( status != WSAEWOULDBLOCK) {  // don't report WOULDBLOCK error
        return ((status << 16) + NET_ERROR);
      }
      size = 0;         // no data sent
      return NET_OK;    // no connection yet
    }
    s = tempSock;       // TCP client connected
    type = CONNECTED_TCP;
  }

  if(mode == CLIENT && type == UNCONNECTED_TCP) {
    ret = connect(s,(SOCKADDR*)(&remote),sizeof(remote));
    if (ret == SOCKET_ERROR) {
      status = WSAGetLastError();
      if ( status == WSAEISCONN) {       // if connected
        ret = 0;          // clear SOCKET_ERROR
        type = CONNECTED_TCP;
      } else {
        if ( status == WSAEWOULDBLOCK || status == WSAEALREADY) {
          size = 0;       // no data sent
          return NET_OK;  // no connection yet
        } else {
          return ((status << 16) + NET_ERROR);
        }
      }
    }
  }

  ret = sendto(s, data, size, 0, (SOCKADDR *)&remote, sizeof(remote));
  if (ret == SOCKET_ERROR) {
    status = WSAGetLastError();
    return ((status << 16) + NET_ERROR);
  }
  size = ret;           // number of bytes sent, may be 0
  return NET_OK;
}

//---------------------------------------------------------------------------
// Read data from remote
int __fastcall netReadData(char *data, int &size, char *senderIP) {
  int status;

  if(mode == SERVER && type == UNCONNECTED_TCP) {
    listen(s,1);
    SOCKET tempSock;
    tempSock = accept(s,NULL,NULL);
    if (tempSock == INVALID_SOCKET) {
      status = WSAGetLastError();
      if ( status != WSAEWOULDBLOCK) {  // don't report WOULDBLOCK error
        return ((status << 16) + NET_ERROR);
      }
      size = 0;         // 0 bytes read
      return NET_OK;    // no connection yet
    }
    s = tempSock;       // TCP client connected
    type = CONNECTED_TCP;
  }

  if(mode == CLIENT && type == UNCONNECTED_TCP) {
    ret = connect(s,(SOCKADDR*)(&remote),sizeof(remote));
    if (ret == SOCKET_ERROR) {
      status = WSAGetLastError();
      if ( status == WSAEISCONN) {       // if connected
        ret = 0;          // clear SOCKET_ERROR
        type = CONNECTED_TCP;
      } else {
        if ( status == WSAEWOULDBLOCK || status == WSAEALREADY) {
          size = 0;       // no data sent
          return NET_OK;  // no connection yet
        } else {
          return ((status << 16) + NET_ERROR);
        }
      }
    }
  }

  dwSenderSize = sizeof(remote);
  ret = recvfrom(s, data, size, 0, (SOCKADDR *)&remote, (int *)&dwSenderSize);
  if (ret == SOCKET_ERROR) {
    status = WSAGetLastError();
    if ( status != WSAEWOULDBLOCK) {  // don't report WOULDBLOCK error
      return ((status << 16) + NET_ERROR);
    }
    ret = 0;            // clear SOCKET_ERROR
  } else if(ret == 0 && type == CONNECTED_TCP) { // if TCP connection did graceful close
    return ((REMOTE_DISCONNECT << 16) + NET_ERROR);     // retur Remote Disconnect error
  }
  if (ret)
    strncpy(senderIP, inet_ntoa(remote.sin_addr), 16);  //IP of sender
  size = ret;           // number of bytes read, may be 0
  return NET_OK;
}

//--------------------------------------------------------------------------
// Close socket and free buffers
//
int __fastcall netCloseSockets() {
  int status;
  BOOL linger;

  type = UNCONNECTED;

  //setsockopt(s, SOL_SOCKET, SO_DONTLINGER, (char *)&linger, sizeof(BOOL));
  // closesocket() implicitly causes a shutdown sequence to occur
  if (closesocket(s) == SOCKET_ERROR) {
    status = WSAGetLastError();
    if ( status != WSAEWOULDBLOCK) {  // don't report WOULDBLOCK error
      return ((status << 16) + NET_ERROR);
    }
  }

  GlobalFree(sendbuf);
  GlobalFree(recvbuf);
  netInitialized = false;

  if (WSACleanup())
    return NET_ERROR;
  return NET_OK;
}

//-------------------------------------------------------------------------
// Get the IP address of this computer as a string
int __fastcall netLocalIP(char *localIP) {

  char hostName[40];
  hostent* host;
  int status;

  gethostname (hostName,40);
  host = gethostbyname(hostName);
  if(host == NULL) {                    // if gethostbyname failed
    status = WSAGetLastError();         // get detailed error
    return ( (status << 16) + NET_ERROR);
  }

  sprintf(localIP, "%d.%d.%d.%d",
          (unsigned char)host->h_addr_list[0][0],
          (unsigned char)host->h_addr_list[0][1],
          (unsigned char)host->h_addr_list[0][2],
          (unsigned char)host->h_addr_list[0][3]);
  return NET_OK;
}




