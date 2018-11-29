require 'asciidoctor'

cmd = ENV['ASCIIDOCTOR_COMMAND']
regex = ENV['GUARD_WATCH']

guard 'shell' do
  watch(Regexp.new regex) {|m|
    IO.popen(cmd) { | out |
      puts "Run: #{cmd}"
      puts out.gets
      puts "Done!"
    }
  }
end
