require 'erb'
require 'yaml'

def symbolize_keys(h)
  Hash[
    h.map { |k, v|
      v = symbolize_keys(v) if v.is_a? Hash
      [k.to_sym, v]
    }
  ]
end

config = YAML::load_file(File.join(File.dirname(__FILE__), '../config/manifest.yml'))
config = symbolize_keys(config)
puts "Loaded config: #{config.inspect}\n"

Dir["#{File.dirname(__FILE__)}/../config/*.erb"].each { |t|

  puts "Processing: #{t}\n"

  template = ERB.new(t)
  config_file = template.result(binding)

  puts "Generated config file:\n#{config_file}"

  begin
    file = File.open("#{File.basename(t)}", "w+")
    file.write(config_file)
  rescue => e
    puts "Failed to write config file: #{t}.yml because of: #{e.inspect}"
  ensure
    file.close if file
  end
}

