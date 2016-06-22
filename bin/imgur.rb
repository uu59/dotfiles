#!/usr/bin/env ruby

# (died) from http://sirupsen.com/a-simple-imgur-bash-screenshot-utility/
#API_KEY = "486690f872c678126a2c09a9e196ce1b"

# from earthquake.gem
# https://gist.github.com/2901301
API_KEY = "5cb04404b1ff26a88cbfe42de5aba23f"
client_id = "ca82b78582ae88f"

# setting
browser_cmd = 'open'
browser_cmd = "google-chrome --incognito"
browser_cmd = "xdg-open"
browser_cmd = "vivaldi-stable"
# or directly browser_cmd = 'chromium-browser'

require "erb"
require "optparse"
require 'net/https'
require "resolv-replace"
require "json"
require "timeout"
require "grill"
Grill.implant <<GEMFILE
gem "httpclient"
GEMFILE

options = {
  :timeout => 3,
  :search => true,
}
OptionParser.new do |opts|
  opts.on('-s', '--search', 'search image by Google'){|v| options[:search] = true}
  opts.on('-t VAL','--timeout=VAL', 'timeout in seconds'){|v| options[:timeout] = v.to_i}
  opts.on('-t VAL','--timeout=VAL', 'timeout in seconds'){|v| options[:timeout] = v.to_i}
  opts.parse!(ARGV)
end

logfile = "#{ENV["HOME"]}/.imgur.log"
imagefile = ARGV[0]

if imagefile && File.exist?(imagefile)
  tmpfile = "/tmp/image_upload#{$$}#{File.extname(imagefile)}"
  system "convert", imagefile,  tmpfile
else
  tmpfile = "/tmp/image_upload#{$$}.png"
  capture_cmd = case RUBY_PLATFORM
    when /darwin/
      "screencapture -i #{tmpfile}"
    else
      "import #{tmpfile}"
  end
  system capture_cmd
end

if system("which mogrify > /dev/null")
  system("mogrify","-strip",tmpfile)
elsif system("which jhead > /dev/null")
  system("jhead","-purejpg",tmpfile)
end

client = HTTPClient.new
# client.debug_dev = STDOUT

begin
  puts "start uploading #{tmpfile} (#{File.size(tmpfile) / 1024} KB)"
  auth_header = {
    "Authorization" => "Client-ID #{client_id}"
  }
  rs = client.post("https://api.imgur.com/3/image", {
    key: API_KEY,
    image: File.open(tmpfile),
    # image: "#{[File.read(tmpfile)].pack('m').gsub(/[^a-zA-Z0-9]/){|m| "%%%02X" % m.ord}}"
  }, auth_header)
      res = JSON.parse(rs.body)
      puts "url: #{res["data"]["link"]}"
      #links = res["upload"]["links"]
      #puts "img: #{links["original"]}"
      #puts "delete: #{links["delete_page"]}"
      #puts "imgur: #{links["imgur_page"]}"
      #system "#{browser_cmd} '#{links["original"]}'"
      if options[:search]
        system(browser_cmd, "http://images.google.com/searchbyimage?image_url=#{ERB::Util.u(res["data"]["link"])}")
      end
      puts
      print "Enter to delete (#{options[:timeout]} seconds)"
      begin
        Timeout.timeout(options[:timeout]) do
          STDIN.gets
        end
        raise Timeout::Error, "foo"
      rescue Timeout::Error
        res = client.delete("https://api.imgur.com/3/image/#{res["data"]["deletehash"]}", {}, auth_header)
        if res.status >= 300
          puts
          p res.body
        else
          puts "Done."
        end
      end

rescue => ex
  p ex
  if File.exists?(tmpfile)
    puts "you can retry uploading '#{$0} #{tmpfile}'"
  end
ensure
  File.delete(tmpfile)
end

=begin
{"upload"=>
  {"image"=>
    {"name"=>nil,
     "title"=>nil,
     "caption"=>nil,
     "hash"=>"V1Z7v",
     "deletehash"=>"ZtUYtG3Cw38LqOn",
     "datetime"=>"2011-04-12 06:45:38",
     "type"=>"image/png",
     "animated"=>"false",
     "width"=>100,
     "height"=>100,
     "size"=>2434,
     "views"=>0,
     "bandwidth"=>0},
   "links"=>
    {"original"=>"http://imgur.com/V1Z7v.png",
     "imgur_page"=>"http://imgur.com/V1Z7v",
     "delete_page"=>"http://imgur.com/delete/ZtUYtG3Cw38LqOn",
     "small_square"=>"http://imgur.com/V1Z7vs.jpg",
     "large_thumbnail"=>"http://imgur.com/V1Z7vl.jpg"}}}
=end
