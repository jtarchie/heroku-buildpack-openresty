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
      "web" => 'ruby runner.rb'
    }
  end

  def compile
    download_openresty
    copy_runner
    FileUtils.mkdir_p "logs"
    FileUtils.mkdir_p "tmp"
  end

  private

  def copy_runner
    runner_path = "runner.rb"
    unless cache_load(runner_path)
      Dir.chdir(build_path) do
        run("cp #{File.join(File.dirname(__FILE__),"..","scripts","runner.rb")} runner.rb")
        cache_load(runner_path)
      end
    end
  end

  def download_openresty
    openresty_path = "openresty"
    topic "Installing OpenResty version #{OPENRESTY_STABLE_VERSION}"
    unless cache_load(openresty_path)
      puts "Downloading OpenResty binary"
      Dir.chdir(build_path) do
        run("curl #{VENDOR_URL}/openresty_nginx-#{OPENRESTY_STABLE_VERSION}.tar.gz -s -o - | tar zxf -")
        cache_store(openresty_path)
      end
    end
  end

  def default_path
    "bin:/bin:/usr/local/bin:/usr/bin:/bin:/app/openresty/nginx/sbin"
  end
end
