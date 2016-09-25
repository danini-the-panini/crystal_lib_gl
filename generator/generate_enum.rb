require_relative 'generate_common'

module GLEnumCodeGenerator

  def self.remove_gl_prefix(enum_name)
    return enum_name if enum_name =~ /^GL_\d/
    enum_name.gsub(/^GL_/, '')
  end

  def self.generate_enum( out )

    doc = REXML::Document.new(open("./gl.xml"))

    gl_std_enum_map = GLCodeGeneratorCommon.build_enums_map(doc)

    # Output
    out.puts GLCodeGeneratorCommon::HeaderComment
    out.puts ""
    out.puts '@[Link("GL")]'
    out.puts "lib LibGL"
    out.puts ""
    gl_std_enum_map.each do |enum|
      out.print "  #{remove_gl_prefix(enum[0])} = #{enum[1]}\n"
    end
    out.puts ""
    out.puts "end"

  end

end

if __FILE__ == $0
  GLEnumCodeGenerator.generate_enum( $stdout )
end
