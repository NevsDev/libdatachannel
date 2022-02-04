

const
  RTC_ENABLE_WEBSOCKET* {.booldefine.} = true
  RTC_ENABLE_MEDIA* {.booldefine.} = true
  RTC_DEFAULT_MTU* = 1280

when RTC_ENABLE_MEDIA:
  const
    RTC_DEFAULT_MAXIMUM_FRAGMENT_SIZE* = ((uint16)(RTC_DEFAULT_MTU - 12 - 8 - 40)) ##  SRTP/UDP/IPv6
    RTC_DEFAULT_MAXIMUM_PACKET_COUNT_FOR_NACK_CACHE* = (cast[cuint](512))


type
  ##  video
  ReadyState* {.pure.} = enum
    RTC_STATE_NEW = 0,
    RTC_STATE_CONNECTING = 1
    RTC_STATE_CONNECTED = 2
    RTC_STATE_DISCONNECTED = 3
    RTC_STATE_FAILED = 4
    RTC_STATE_CLOSED = 5
    
  rtcGatheringState* = enum
    RTC_GATHERING_NEW = 0
    RTC_GATHERING_INPROGRESS = 1
    RTC_GATHERING_COMPLETE = 2

  rtcSignalingState* = enum
    RTC_SIGNALING_STABLE = 0
    RTC_SIGNALING_HAVE_LOCAL_OFFER = 1
    RTC_SIGNALING_HAVE_REMOTE_OFFER = 2
    RTC_SIGNALING_HAVE_LOCAL_PRANSWER = 3
    RTC_SIGNALING_HAVE_REMOTE_PRANSWER = 4

  RTCLogLevel* = enum
    NONE = 0
    FATAL = 1
    ERROR = 2
    WARNING = 3
    INFO = 4
    DEBUG = 5
    VERBOSE = 6

  rtcCertificateType* = enum
    RTC_CERTIFICATE_DEFAULT = 0 ##  ECDSA
    RTC_CERTIFICATE_ECDSA = 1
    RTC_CERTIFICATE_RSA = 2

  rtcCodec* = enum
    RTC_CODEC_H264 = 0
    RTC_CODEC_VP8 = 1
    RTC_CODEC_VP9 = 2
    RTC_CODEC_OPUS = 128

  rtcDirection* = enum
    RTC_DIRECTION_UNKNOWN = 0
    RTC_DIRECTION_SENDONLY = 1
    RTC_DIRECTION_RECVONLY = 2
    RTC_DIRECTION_SENDRECV = 3
    RTC_DIRECTION_INACTIVE = 4

  rtcTransportPolicy* = enum
    RTC_TRANSPORT_POLICY_ALL = 0
    RTC_TRANSPORT_POLICY_RELAY = 1


const
  RTC_ERR_SUCCESS* = 0
  RTC_ERR_INVALID* = -1
  RTC_ERR_FAILURE* = -2
  RTC_ERR_NOT_AVAIL* = -3
  RTC_ERR_TOO_SMALL* = -4

{.push cdecl.}
type
  rtcLogCallbackFunc* = proc (level: RTCLogLevel; message: cstring)
  rtcDescriptionCallbackFunc* = proc (pc: cint; sdp: cstring; `type`: cstring; `ptr`: pointer)
  rtcCandidateCallbackFunc* = proc (pc: cint; cand: cstring; mid: cstring; `ptr`: pointer)
  rtcStateChangeCallbackFunc* = proc (pc: cint; state: ReadyState; `ptr`: pointer)
  rtcGatheringStateCallbackFunc* = proc (pc: cint; state: rtcGatheringState; `ptr`: pointer)
  rtcSignalingStateCallbackFunc* = proc (pc: cint; state: rtcSignalingState; `ptr`: pointer)
  rtcDataChannelCallbackFunc* = proc (pc: cint; dc: cint; `ptr`: pointer)
  rtcTrackCallbackFunc* = proc (pc: cint; tr: cint; `ptr`: pointer)
  rtcOpenCallbackFunc* = proc (id: cint; `ptr`: pointer)
  rtcClosedCallbackFunc* = proc (id: cint; `ptr`: pointer)
  rtcErrorCallbackFunc* = proc (id: cint; error: cstring; `ptr`: pointer)
  rtcMessageCallbackFunc* = proc (id: cint; message: cstring; size: cint; `ptr`: pointer)
  rtcBufferedAmountLowCallbackFunc* = proc (id: cint; `ptr`: pointer)
  rtcAvailableCallbackFunc* = proc (id: cint; `ptr`: pointer)

{.pop.}

import os


# const dllPath = currentSourcePath().parentDir() / "libs/mac/arm64"
const dllPath = currentSourcePath().parentDir() / "libs/mac/x86_64"
when defined(windows):
  {.push importc, dynlib: "libdatachannel.dll".}
elif defined(macosx):
  {.push importc, dynlib: dllPath / "libdatachannel.dylib".}
else:
  {.push importc, dynlib: "libdatachannel.so".}

proc rtcInitLogger*(level: RTCLogLevel; cb: rtcLogCallbackFunc) 
  ##  Log
  ##  NULL cb on the first call will log to stdout
##  User pointer

proc rtcSetUserPointer*(id: cint; `ptr`: pointer)
proc rtcGetUserPointer*(i: cint): pointer
##  PeerConnection

type
  RTCConfiguration* {.bycopy.} = object
    iceServers*: cstringArray
    iceServersCount*: cint
    bindAddress*: cstring      ##  libjuice only, NULL means any
    certificateType*: rtcCertificateType
    iceTransportPolicy*: rtcTransportPolicy
    enableIceTcp*: bool
    disableAutoNegotiation*: bool
    portRangeBegin*: uint16    ##  0 means automatic
    portRangeEnd*: uint16      ##  0 means automatic
    mtu*: cint                 ##  <= 0 means automatic
    maxMessageSize*: cint      ##  <= 0 means default


proc rtcCreatePeerConnection*(config: var RTCConfiguration): cint
##  returns pc id

proc rtcDeletePeerConnection*(pc: cint): cint
proc rtcSetLocalDescriptionCallback*(pc: cint; cb: rtcDescriptionCallbackFunc): cint
proc rtcSetLocalCandidateCallback*(pc: cint; cb: rtcCandidateCallbackFunc): cint
proc rtcSetStateChangeCallback*(pc: cint; cb: rtcStateChangeCallbackFunc): cint
proc rtcSetGatheringStateChangeCallback*(pc: cint; cb: rtcGatheringStateCallbackFunc): cint
proc rtcSetSignalingStateChangeCallback*(pc: cint; cb: rtcSignalingStateCallbackFunc): cint
proc rtcSetLocalDescription*(pc: cint; `type`: cstring): cint
proc rtcSetRemoteDescription*(pc: cint; sdp: cstring; `type`: cstring): cint
proc rtcAddRemoteCandidate*(pc: cint; cand: cstring; mid: cstring): cint
proc rtcGetLocalDescription*(pc: cint; buffer: cstring; size: cint): cint
proc rtcGetRemoteDescription*(pc: cint; buffer: cstring; size: cint): cint
proc rtcGetLocalDescriptionType*(pc: cint; buffer: cstring; size: cint): cint
proc rtcGetRemoteDescriptionType*(pc: cint; buffer: cstring; size: cint): cint
proc rtcGetLocalAddress*(pc: cint; buffer: cstring; size: cint): cint
proc rtcGetRemoteAddress*(pc: cint; buffer: cstring; size: cint): cint
proc rtcGetSelectedCandidatePair*(pc: cint; local: cstring; localSize: cint; remote: cstring; remoteSize: cint): cint
##  DataChannel, Track, and WebSocket common API

proc rtcSetOpenCallback*(id: cint; cb: rtcOpenCallbackFunc): cint 
proc rtcSetClosedCallback*(id: cint; cb: rtcClosedCallbackFunc): cint
proc rtcSetErrorCallback*(id: cint; cb: rtcErrorCallbackFunc): cint
proc rtcSetMessageCallback*(id: cint; cb: rtcMessageCallbackFunc): cint
proc rtcSendMessage*(id: cint; data: cstring; size: cint): cint
proc rtcIsOpen*(id: cint): bool
proc rtcIsClosed*(id: cint): bool
proc rtcGetBufferedAmount*(id: cint): cint
##  total size buffered to send

proc rtcSetBufferedAmountLowThreshold*(id: cint; amount: cint): cint
proc rtcSetBufferedAmountLowCallback*(id: cint; cb: rtcBufferedAmountLowCallbackFunc): cint
##  DataChannel, Track, and WebSocket common extended API

proc rtcGetAvailableAmount*(id: cint): cint
##  total size available to receive

proc rtcSetAvailableCallback*(id: cint; cb: rtcAvailableCallbackFunc): cint
proc rtcReceiveMessage*(id: cint; buffer: cstring; size: ptr cint): cint
##  DataChannel

type
  RTCReliability* {.bycopy.} = object
    unordered*: bool
    unreliable*: bool
    maxPacketLifeTime*: cint   ##  ignored if reliable
    maxRetransmits*: cint      ##  ignored if reliable

  RTCDataChannelInit* {.bycopy.} = object
    reliability*: RTCReliability
    protocol*: cstring         ##  empty string if NULL
    negotiated*: bool
    manualStream*: bool
    stream*: uint16            ##  numeric ID 0-65534, ignored if manualStream is false


proc rtcSetDataChannelCallback*(pc: cint; cb: rtcDataChannelCallbackFunc): cint
proc rtcCreateDataChannel*(pc: cint; label: cstring): cint
##  returns dc id

proc rtcCreateDataChannelEx*(pc: cint; label: cstring; init: ptr RTCDataChannelInit): cint
##  returns dc id

proc rtcDeleteDataChannel*(dc: cint): cint
proc rtcGetDataChannelStream*(dc: cint): cint
proc rtcGetDataChannelLabel*(dc: cint; buffer: cstring; size: cint): cint
proc rtcGetDataChannelProtocol*(dc: cint; buffer: cstring; size: cint): cint
proc rtcGetDataChannelReliability*(dc: cint; reliability: ptr RTCReliability): cint
##  Track

type
  RTCTrackInit* {.bycopy.} = object
    direction*: rtcDirection
    codec*: rtcCodec
    payloadType*: cint
    ssrc*: uint32
    mid*: cstring
    name*: cstring             ##  optional
    msid*: cstring             ##  optional
    trackId*: cstring          ##  optional, track ID used in MSID


proc rtcSetTrackCallback*(pc: cint; cb: rtcTrackCallbackFunc): cint
proc rtcAddTrack*(pc: cint; mediaDescriptionSdp: cstring): cint
##  returns tr id

proc rtcAddTrackEx*(pc: cint; init: ptr RTCTrackInit): cint
##  returns tr id

proc rtcDeleteTrack*(tr: cint): cint
proc rtcGetTrackDescription*(tr: cint; buffer: cstring; size: cint): cint

when RTC_ENABLE_MEDIA:
  ##  Media
  ##  Define how NAL units are separated in a H264 sample
  type
    RTCNalUnitSeparator* = enum
      RTC_NAL_SEPARATOR_LENGTH = 0, ##  first 4 bytes are NAL unit length
      RTC_NAL_SEPARATOR_LONG_START_SEQUENCE = 1, ##  0x00, 0x00, 0x00, 0x01
      RTC_NAL_SEPARATOR_SHORT_START_SEQUENCE = 2, ##  0x00, 0x00, 0x01
      RTC_NAL_SEPARATOR_START_SEQUENCE = 3 ##  long or short start sequence
    RTCPacketizationHandlerInit* {.bycopy.} = object
      ssrc*: uint32  
      cname*: cstring
      payloadType*: uint8
      clockRate*: uint32  
      sequenceNumber*: uint16  
      timestamp*: uint32       ##  H264
      nalSeparator*: RTCNalUnitSeparator ##  NAL unit separator
      maxFragmentSize*: uint16   ##  Maximum NAL unit fragment size

    RTCStartTime* {.bycopy.} = object
      seconds*: cdouble        ##  Start time in seconds
      since1970*: bool         ##  true if seconds since 1970
                     ##  false if seconds since 1900
      timestamp*: uint32       ##  Start timestamp

    RTCSsrcForTypeInit* {.bycopy.} = object
      ssrc*: uint32  
      name*: cstring           ##  optional
      msid*: cstring           ##  optional
      trackId*: cstring        ##  optional, track ID used in MSID

  ##  Set H264PacketizationHandler for track
  proc rtcSetH264PacketizationHandler*(tr: cint;
                                      init: ptr RTCPacketizationHandlerInit): cint
  ##  Set OpusPacketizationHandler for track
  proc rtcSetOpusPacketizationHandler*(tr: cint;
                                      init: ptr RTCPacketizationHandlerInit): cint
  ##  Chain RtcpSrReporter to handler chain for given track
  proc rtcChainRtcpSrReporter*(tr: cint): cint
  ##  Chain RtcpNackResponder to handler chain for given track
  proc rtcChainRtcpNackResponder*(tr: cint; maxStoredPacketsCount: cuint): cint
  ## / Set start time for RTP stream
  proc rtcSetRtpConfigurationStartTime*(id: cint; startTime: ptr RTCStartTime): cint
  ##  Start stats recording for RTCP Sender Reporter
  proc rtcStartRtcpSenderReporterRecording*(id: cint): cint
  ##  Transform seconds to timestamp using track's clock rate, result is written to timestamp
  proc rtcTransformSecondsToTimestamp*(id: cint; seconds: cdouble;
                                      timestamp: ptr uint32  ): cint
  ##  Transform timestamp to seconds using track's clock rate, result is written to seconds
  proc rtcTransformTimestampToSeconds*(id: cint; timestamp: uint32; seconds: ptr cdouble): cint
  ##  Get current timestamp, result is written to timestamp
  proc rtcGetCurrentTrackTimestamp*(id: cint; timestamp: ptr uint32): cint
  ##  Get start timestamp for track identified by given id, result is written to timestamp
  proc rtcGetTrackStartTimestamp*(id: cint; timestamp: ptr uint32): cint
  ##  Set RTP timestamp for track identified by given id
  proc rtcSetTrackRtpTimestamp*(id: cint; timestamp: uint32): cint
  ##  Get timestamp of previous RTCP SR, result is written to timestamp
  proc rtcGetPreviousTrackSenderReportTimestamp*(id: cint; timestamp: ptr uint32): cint
  ##  Set NeedsToReport flag in RtcpSrReporter handler identified by given track id
  proc rtcSetNeedsToSendRtcpSr*(id: cint): cint
  ##  Get all available payload types for given codec and stores them in buffer, does nothing if
  ##  buffer is NULL
  proc rtcGetTrackPayloadTypesForCodec*(tr: cint; ccodec: cstring; buffer: ptr cint; size: cint): cint
  ##  Get all SSRCs for given track
  proc rtcGetSsrcsForTrack*(tr: cint; buffer: ptr uint32; count: cint): cint
  ##  Get CName for SSRC
  proc rtcGetCNameForSsrc*(tr: cint; ssrc: uint32; cname: cstring; cnameSize: cint): cint
  ##  Get all SSRCs for given media type in given SDP
  proc rtcGetSsrcsForType*(mediaType: cstring; sdp: cstring; buffer: ptr uint32; bufferSize: cint): cint
  ##  Set SSRC for given media type in given SDP
  proc rtcSetSsrcForType*(mediaType: cstring; sdp: cstring; buffer: cstring; bufferSize: cint; init: ptr RTCSsrcForTypeInit): cint

when RTC_ENABLE_WEBSOCKET:
  ##  WebSocket
  type
    RTCWsConfiguration* = object
      disableTlsVerification*: bool ##  if true, don't verify the TLS certificate

  proc rtcCreateWebSocket*(url: cstring): cint
  ##  returns ws id
  proc rtcCreateWebSocketEx*(url: cstring; config: var RTCWsConfiguration): cint
  proc rtcDeleteWebSocket*(ws: cint): cint
  proc rtcGetWebSocketRemoteAddress*(ws: cint; buffer: cstring; size: cint): cint
  proc rtcGetWebSocketPath*(ws: cint; buffer: cstring; size: cint): cint
  ##  WebSocketServer
  type
    RTCWebSocketClientCallbackFunc* = proc (wsserver: cint; ws: cint; `ptr`: pointer)
    RTCWsServerConfiguration* {.bycopy.} = object
      port*: uint16            ##  0 means automatic selection
      enableTls*: bool         ##  if true, enable TLS (WSS)
      certificatePemFile*: cstring ##  NULL for autogenerated certificate
      keyPemFile*: cstring     ##  NULL for autogenerated certificate
      keyPemPass*: cstring     ##  NULL if no pass

  proc rtcCreateWebSocketServer*(config: ptr RTCWsServerConfiguration; cb: RTCWebSocketClientCallbackFunc): cint
  ##  returns wsserver id
  proc rtcDeleteWebSocketServer*(wsserver: cint): cint
  proc rtcGetWebSocketServerPort*(wsserver: cint): cint
##  Optional global preload and cleanup

proc rtcPreload*()
proc rtcCleanup*()
##  SCTP global settings

type
  RTCSctpSettings* {.bycopy.} = object
    recvBufferSize*: cint      ##  in bytes, <= 0 means optimized default
    sendBufferSize*: cint      ##  in bytes, <= 0 means optimized default
    maxChunksOnQueue*: cint    ##  in chunks, <= 0 means optimized default
    initialCongestionWindow*: cint ##  in MTUs, <= 0 means optimized default
    maxBurst*: cint            ##  in MTUs, 0 means optimized default, < 0 means disabled
    congestionControlModule*: cint ##  0: RFC2581 (default), 1: HSTCP, 2: H-TCP, 3: RTCC
    delayedSackTimeMs*: cint   ##  in msecs, 0 means optimized default, < 0 means disabled
    minRetransmitTimeoutMs*: cint ##  in msecs, <= 0 means optimized default
    maxRetransmitTimeoutMs*: cint ##  in msecs, <= 0 means optimized default
    initialRetransmitTimeoutMs*: cint ##  in msecs, <= 0 means optimized default
    maxRetransmitAttempts*: cint ##  number of retransmissions, <= 0 means optimized default
    heartbeatIntervalMs*: cint ##  in msecs, <= 0 means optimized default


##  Note: SCTP settings apply to newly-created PeerConnections only

proc rtcSetSctpSettings*(settings: ptr RTCSctpSettings): cint

{.pop.}

when isMainModule:
  import os

  rtcInitLogger(RTCLogLevel.Debug, nil) 

  const myMessage = "Hello world from libdatachannel"
  var received = false

  var config: RTCWsConfiguration
  config.disableTlsVerification = true

  var ws = rtcCreateWebSocketEx("wss://www.example.com/socketserver", config)

  discard rtcSetOpenCallback(
    ws,
    proc(id: cint; `ptr`: pointer) =
      echo "WebSocket: Open"
      discard rtcSendMessage(id, myMessage.cstring, myMessage.len)
  )

  discard rtcSetClosedCallback(
    ws,
    proc(id: cint; `ptr`: pointer) =
      echo "WebSocket: Closed"
  )

  discard rtcSetErrorCallback(
    ws,
    proc(id: cint; error: cstring; `ptr`: pointer) =
      echo "WebSocket: Error - " & $error
  )

  discard rtcSetMessageCallback(
    ws,
    proc (id: cint; message: cstring; size: cint; `ptr`: pointer) =
      received = true
      echo "WebSocket: Message - " & $message
  )

  var attempts = 10
  while rtcIsOpen(ws) and attempts >= 0:
    attempts.dec
    sleep(1000)

  if not rtcIsOpen(ws):
    echo "Websocket is not open"

  if not received:
    raise newException(Exception, "Expected message not received")

  discard rtcDeleteWebSocket(ws)
  sleep(1000)

  echo "Success"