# (Execution example)
# $ ruby aux_generate_typemap.rb > aux_typemap.rb
# $ head aux_typemap.rb
# # [NOTICE] Automatically generated file
# module OpenGL
#   GL_TYPE_MAP = {
#     'GLenum' => 'Enum',
#     'GLboolean' => 'Boolean',
#     'GLbitfield' => 'BitField',
#     'GLvoid' => 'Void',
#     'GLbyte' => 'Byte',
#     'GLshort' => 'Short',
#     'GLint' => 'Int',
# $

require 'rexml/document'
require 'fiddle'

CToCrystalTypeMap = {
  'char' => 'Int8',
  'signed char' => 'Int8',
  'unsigned char' => 'UInt8',
  'short' => 'Int16',
  'signed short' => 'Int16',
  'unsigned short' => 'UInt16',
  'int' => 'Int32',
  'signed int' => 'Int32',
  'unsigned int' => 'UInt32',
  'int64_t' => 'LibC::Int64T',
  'uint64_t' => 'LibC::UInt64T',
  'float' => 'Float32',
  'double' => 'Float64',
  'ptrdiff_t' => 'PtrDiffT',
  'void' => 'Void',
  'void *' => 'Void*',
}

GLToCrystalTypeMap = {
  'GLenum' => 'Enum',
  'GLboolean' => 'Boolean',
  'GLbitfield' => 'BitField',
  'GLvoid' => 'Void',
  'GLbyte' => 'Byte',
  'GLshort' => 'Short',
  'GLint' => 'Int',
  'GLclampx' => 'ClampX',
  'GLubyte' => 'UByte',
  'GLushort' => 'UShort',
  'GLuint' => 'UInt',
  'GLsizei' => 'SizeI',
  'GLfloat' => 'Float',
  'GLclampf' => 'ClampF',
  'GLdouble' => 'Double',
  'GLclampd' => 'ClampD',
  'GLeglImageOES' => 'EGLImageOES',
  'GLchar' => 'Char',
  'GLcharARB' => 'CharARB',
  'GLhandleARB' => 'HandleARB',
  'GLhalfARB' => 'HalfARB',
  'GLhalf' => 'Half',
  'GLfixed' => 'Fixed',
  'GLintptr' => 'IntPtr',
  'GLsizeiptr' => 'SizeIPtr',
  'GLint64' => 'Int64',
  'GLuint64' => 'UInt64',
  'GLintptrARB' => 'IntPtrARB',
  'GLsizeiptrARB' => 'SizeIPtrARB',
  'GLint64EXT' => 'Int64EXT',
  'GLuint64EXT' => 'UInt64EXT',
  'GLsync' => 'Sync',
  # 'struct _cl_context' => 'VoidP'
  # 'struct _cl_event' => 'VoidP'
  'GLDEBUGPROC' => 'DebugProc',
  'GLDEBUGPROCARB' => 'DebugProcARB',
  'GLDEBUGPROCKHR' => 'DebugProcKHR',
  'GLDEBUGPROCAMD' => 'DebugProcAMD',
  'GLhalfNV' => 'HalfNV',
  'GLvdpauSurfaceNV' => 'VDPAUSurfaceNV',
}

GLTypeMapEntry = Struct.new( :def_name, :ctype_name )
gl_type_map = []

doc = REXML::Document.new(open("./gl.xml"))

REXML::XPath.each(doc, 'registry/types/type') do |type_tag|
  # Skip stddef/khrplatform/inttypes to process actual GL types
  name_attr = type_tag.attribute('name')
  next if name_attr != nil && (name_attr.value == 'stddef' || name_attr.value == 'khrplatform' || name_attr.value == 'inttypes')

  # Skip ES1/2 types
  api_attr = type_tag.attribute('api')
  if api_attr != nil
    next if api_attr.value == 'gles1' || api_attr.value == 'gles2'
  end

  # Analyze the content of <type>...</type>
  content = type_tag.text
  name_tag = type_tag.get_elements('name').first

  if name_tag != nil
    # ex.) <type>typedef float <name>GLfloat</name>;</type>
    def_name = name_tag.text.strip # ex.) def_name <- GLfloat
    ctype_name = content.chomp(def_name + ';').sub('typedef ','').strip # ex.) ctype_name <- float
  else
    # The actual type of 'GLhandleARB' should be changed depending on your platform (#ifdef __APPLE__, ...)
    def_name = name_attr.value
    ctype_name = "Needs tweaking by hand..."
  end

  # Store the result into name -> ctype map
  map_entry = GLTypeMapEntry.new
  map_entry.def_name = def_name
  map_entry.ctype_name = ctype_name
  gl_type_map << map_entry
end


if __FILE__ == $0
  puts "# [NOTICE] Automatically generated file"
  puts "module OpenGL"
  puts "  GL_TYPE_MAP = {"

  # Resolve OpenGL types to corresponding Fiddle type ('TYPE_XX')
  gl_type_map.each do |t|
    fiddle_type = CToCrystalTypeMap[t.ctype_name] # ex.) GLint -> TYPE_INT
    comment = nil
    if fiddle_type == nil # GL types defined by typdef of another GL type (GLfixed, etc.).
      fiddle_type = GLToCrystalTypeMap[t.ctype_name] # ex.) GLfixed -> GLint -> TYPE_INT
      if fiddle_type == nil # fallback
        fiddle_type = 'VoidP'
        comment = '<- *** [CHECK] Cannot resolved to any Fiddle type. You might need tweaking for this. ***'
      end
    end
    printf "    '#{t.def_name}' => '#{fiddle_type}',%s\n", (comment ? " # #{comment}" : '')
  end

  puts ""

  # Copy C/C++ type map
  CToCrystalTypeMap.each do |t|
    puts "    '#{t[0]}' => '#{t[1]}',"
  end

  puts "  }"
  puts "end"
end
