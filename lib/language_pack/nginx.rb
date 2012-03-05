require "tmpdir"
require "rubygems"
require "language_pack"
require "language_pack/base"

class LanguagePack::Nginx < LanguagePack::Base
  OPENRESTY_STABLE_VERSION = "1.0.10.48"

  def self.use?
    File.exist?("nginx.conf")
  end

  def name
    "Nginx"
  end

  def default_addons
    ['shared-database:5mb']
  end

  def default_config_vars
    {
      "LANG"     => "en_US.UTF-8",
      "PATH"     => default_path
    }
  end

  def default_process_types
    {
      "web" => 'ruby run.rb'
    }
  end


  def compile
    Dir.chdir(build_path)
    run("curl #{VENDOR_URL}/openresty_nginx-#{OPENRESTY_STABLE_VERSION}.tar.gz -s -o - | tar zxf -")
    FileUtils.mkdir_p "logs"
    File.open("run.rb", "w") do |file|
      file.puts <<-APPLICATION
#!/usr/bin/env ruby

conf_file = File.read("nginx.conf")
conf_file.gsub(/$ENV_(\w+)/) do
  ENV[$1]
end
File.open(".env_nginx.conf","w") do |file|
  file.puts << conf_file
end
`nginx -c \`pwd\`/.env_nginx.conf -g "daemon off;"`
      APPLICATION
    end
  end

  private
  def default_path
    "bin:/bin:/usr/local/bin:/usr/bin:/bin:/app/openresty/nginx/sbin"
  end
end
