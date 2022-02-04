# https://developer.mozilla.org/en-US/docs/Web/API/WebSocket

type
  ReadyState* = enum
    CONNECTING  # Socket has been created. The connection is not yet open.
    OPEN        # The connection is open and ready to communicate.
    CLOSING     # The connection is in the process of closing.
    CLOSED      # The connection is closed or couldn't be opened.
  
  OnEventCallback* = proc(msg: string)

when defined(js):
  type
    WebSocket* {.importc: "WebSocket".} = ref object

  proc new*(w: type WebSocket): WebSocket {.error: "Constructor needs url.".}
  proc newWebsocketRaw(url: cstring): WebSocket {.importcpp: "new Websocket(#)".}
  proc new*(w: type WebSocket, url: string): WebSocket = 
    result = newWebsocketRaw(url.cstring)
    asm """`result`.binaryType = "arraybuffer";"""

  proc urlRaw(w: WebSocket): cstring {.importcpp: "#.url".}
  proc url*(w: WebSocket): string = $w.urlRaw

  proc readyState*(w: WebSocket): ReadyState {.importcpp: "#.readyState".}

  proc closeRaw(w: WebSocket, code: cint, reason: cstring) {.importcpp: "#.close(#,#)".}
  proc close*(w: WebSocket, code: int = 1005, reason: string = ""): WebSocket = w.closeRaw(code.cint, reason.cstring)

  proc send*(w: WebSocket, data: string) = 
    asm "`w`.send(new Uint8Array(`data`));"
    # asm "`w`.send(new Uint16Array(`data`));"


  proc onclose*(w: WebSocket, cb: OnEventCallback) =
    discard
  proc onopen*(w: WebSocket, cb: OnEventCallback) =
    discard
  proc onerror*(w: WebSocket, cb: OnEventCallback) =
    discard
  proc onmessage*(w: WebSocket, cb: OnEventCallback) =
    discard


  var 
    w = Websocket.new("wss://www.example.com/socketserver")

else:
  discard