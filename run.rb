# Require nessecary libraries for the server
require_relative "server"

# Load the local server
puts "Data: #{ARGV[0]}"
@server = LocalServer.new("/server", eval(ARGV[0]))
@server.load!
