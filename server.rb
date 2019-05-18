require_relative "plugin"

# Represents a local Minecraft server in a Docker container.
class LocalServer

  def initialize(path=nil, data={})
    @path = File.expand_path(path || "~")
    @data = data
  end

  # Get the absolute path that the server operates inside.
  def path
    @path
  end

  # Get the data passed in for the server.
  def data
    @data
  end

  # Path of extra config directories to load from
  def load_path
    data[:load_path].nil? ? "" : data[:load_path]
  end

  # Path of plugin configuration files
  def plugins_path
    data[:plugins_path]
  end

  # Array of {spurce: '', destination: ''} hashes demoting files in remote directories
  def remote_files
    data[:remote_files].nil? ? [] : data[:remote_files]
  end

  # Array of {name: '', jar_path: ''} hashes denoting plugins to be loaded
  def plugins
    data[:plugins].nil? ? [] : data[:plugins]
  end

  # Games external components to load in an array of {path: '', name: ''} hashes
  def components
    data[:components].nil? ? [] : data[:components]
  end

  # Environment variables
  def env
    data[:env].nil? ? {} : data[:env]
  end

  # Move over files from the data folder, format plugin configuration files,
  # ensure at least one map available, and inject server variables into text-based files.
  def load!
    plug_path = "#{path}/plugins"
    unless File.directory?(plug_path)
      FileUtils.mkdir_p(plug_path)
    end
    for folder in ["base", load_path]
      FileUtils.copy_entry("/data/servers/#{folder}", "#{path}")
    end
    remote_files.each do |file|
      FileUtils.copy_entry(file[:source], "#{path}/#{file[:destination]}")
    end
    plugins.each do |plugin|
      Plugin.new(plugin[:name]).load_and_save!(
        "/data/plugins/#{plugins_path}",
        plugin[:jar_path],
        "#{path}/plugins"
      )
    end
    unless components.empty?
      comp_path = "#{path}/plugins/GamesCore/components/"
      unless File.directory?(comp_path)
        FileUtils.mkdir_p(comp_path)
      end
      components.each do |component|
        FileUtils.copy_entry(component[:path], "#{path}/plugins/GamesCore/components/#{component[:name]}.jar")
      end
    end
    env.each{|k,v| Env.set(k, v.to_s, true)}
    for file in ["yml", "yaml", "json", "properties"].flat_map{|ext| Dir.glob("#{path}/**/*.#{ext}")}
      data = Env.substitute(File.read(file))
      File.open(file, "w") do |f|
        f.write(data)
      end
    end
  end
end
