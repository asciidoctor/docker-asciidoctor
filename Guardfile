require 'net/http'
require 'asciidoctor'

# cmd = ENV['ASCIIDOCTOR_COMMAND']
# regex = ENV['GUARD_WATCH']
cmd = "/usr/bin/asciidoctor src/index.adoc -r asciidoctor-diagram --out-file target/site/index.html 2>&1"

guard 'shell' do
  watch(/src\/.*adoc/) {|m|
    IO.popen(cmd) { | out |
      puts "Run: #{cmd}"
      puts out.gets
      puts "Done. Reloading browser: " + reload_browser
    }
  }
end

def reload_browser
  uri = URI("http://browser-sync:3000/__browser_sync__?method=reload")
  req = Net::HTTP::Get.new(uri)

  res = Net::HTTP.start(uri.hostname, uri.port) {|http|
    http.request(req)
  }
  puts res
end
