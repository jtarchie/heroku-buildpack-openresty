require "tmpdir"
require "rubygems"
require "language_pack"
require "language_pack/base"

class LanguagePack::Nginx < LanguagePack::Base
  OPENRESTY_STABLE_VERSION = "1.2.1.14"

  def self.use?
    File.exist?("nginx.conf")
  end

  def name
    "OpenResty"
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
      "web" => 'erb nginx.conf > nginx.conf && touch logs/access.log logs/error.log && (tail -f -n 0 logs/*.log &) && nginx -p . -g "daemon off;"'
    }
  end

  def compile
    download_openresty
    FileUtils.mkdir_p "logs"
    FileUtils.mkdir_p "tmp"
  end

  private

  def download_openresty
    openresty_path = "openresty"
    topic "Installing OpenResty version #{openresty_version}"
    unless cache_load(openresty_path)
      puts "Downloading OpenResty binary"
      Dir.chdir(build_path) do
        run("curl #{VENDOR_URL}/openresty_nginx-#{openresty_version}.tar.gz -s -o - | tar zxf -")
        cache_store(openresty_path)
      end
    end
  end

  def openresty_version
    ENV['OPENRESTY_VERSION'] || OPENRESTY_STABLE_VERSION
  end

  def default_path
    "bin:/bin:/usr/local/bin:/usr/bin:/bin:/app/openresty/nginx/sbin"
  end
end
