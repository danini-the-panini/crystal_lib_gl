require "lib_c"

@[Link("GL")]
lib LibGL
  # Crystal doesn't seem to define this anymore
  {% if flag?(:x86_64) %}
    alias PtrDiffT = Int64
  {% else %}
    alias PtrDiffT = Int32
  {% end %}

  alias Enum = UInt32
  alias Boolean = UInt8
  alias BitField = UInt32
  alias Byte = Int8
  alias Short = Int16
  alias Int = Int32
  alias ClampX = Int32
  alias UByte = UInt8
  alias UShort = UInt16
  alias UInt = Int32
  alias SizeI = Int32
  alias Float = Float32
  alias ClampF = Float32
  alias Double = Float64
  alias ClampD = Float64
  alias EGLImageOES = Void*
  alias Char = Int8
  alias CharARB = Int8
  {% if flag?(:apple) %}
    alias HandleARB = Void*
  {% else %}
    alias HandleARB = UInt32
  {% end %}
  alias HalfARB = UInt16
  alias Half = UInt16
  alias Fixed = Int
  alias IntPtr = PtrDiffT
  alias SizeIPtr = PtrDiffT
  alias Int64 = LibC::Int64T
  alias UInt64 = LibC::UInt64T
  alias IntPtrARB = PtrDiffT
  alias SizeIPtrARB = PtrDiffT
  alias Int64EXT = LibC::Int64T
  alias UInt64EXT = LibC::UInt64T

  type Sync = Void* # transparent type? "struct __GLsync *GLSync"

  # "Compatible with OpenCL" ?
  # 'struct _cl_context' = Void*
  # 'struct _cl_event' = Void*

  alias DebugProc = Enum, Enum, UInt, Enum, SizeI, Char*, Void* -> Void
  alias DebugProcARB = Enum, Enum, UInt, Enum, SizeI, Char*, Void* -> Void
  alias DebugProcKHR = Enum, Enum, UInt, Enum, SizeI, Char*, Void* -> Void
  alias DebugProcAMD = UInt, Enum, Enum, SizeI, Char*, Void* -> Void
  alias HalfNV = UInt16
  alias VDPAUSurfaceNV = IntPtr
end
