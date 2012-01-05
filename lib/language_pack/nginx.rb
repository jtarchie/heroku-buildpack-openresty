require "tmpdir"
require "rubygems"
require "language_pack"
require "language_pack/base"

class LanguagePack::Nginx < LanguagePack::Base
  OPENRESTY_STABLE_VERSION = "1.0.10.24"

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
      "web" => 'sed "s/\$port/${PORT}/" `pwd`/nginx.conf > .port_nginx.conf; nginx -c `pwd`/.port_nginx.conf -g "daemon off;"'
    }
  end


  def compile
    Dir.chdir(build_path)
    run("curl #{VENDOR_URL}/openresty_nginx-#{OPENRESTY_STABLE_VERSION}.tar.gz -s -o - | tar zxf -")
    Dir["nginx/nginx/sbin/*"].each {|path| run("chmod +x #{path}") }
    FileUtils.mkdir_p "logs"
  end

  private 
  def default_path
    "bin:/bin:/usr/local/bin:/usr/bin:/bin:/app/openresty/nginx/nginx/sbin"
  end
end
