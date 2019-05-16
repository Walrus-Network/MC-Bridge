# Require nessecary libraries for the server
require_relative "server"
require "json"

# Load the local server
puts "Data: #{ARGV[0]}"
@server = LocalServer.new("/server", JSON.parse(ARGV[0]))
@server.load!
