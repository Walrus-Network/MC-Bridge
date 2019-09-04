# Require nessecary libraries for the server
require_relative "server"

# Load the local server
@server = LocalServer.new("/server", eval(ARGV[0]))
puts @server.describe
@server.load!
