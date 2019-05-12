# Require nessecary libraries for the server
require "server"
require "json"

# Load the local server
@server = LocalServer.new("/server", JSON.parse(ARGV[0]))
@server.load!
