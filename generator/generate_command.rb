require_relative 'generate_common'

module GLCommandCodeGenerator

  def self.generate_command( out )

    doc = REXML::Document.new(open("./gl.xml"))

    gl_std_cmd_map = GLCodeGeneratorCommon.build_commands_map(doc, extract_api: "gl")

    # Output
    out.puts GLCodeGeneratorCommon::HeaderComment
    out.puts 'require "./types"'
    out.puts ""
    out.puts '@[Link("GL")]'
    out.puts "lib LibGL"
    out.puts ""

    GLCodeGeneratorCommon.generate_method(out, gl_std_cmd_map)

  end

end

if $0 == __FILE__
  GLCommandCodeGenerator.generate_command( $stdout )
end
