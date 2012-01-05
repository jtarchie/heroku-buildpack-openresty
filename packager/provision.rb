class Provision < Vagrant::Provisioners::Base
  OPENRESTY_STABLE_VERSION = "1.0.10.24"

  def provision!
    vm.ssh.execute do |ssh|
      ssh.sudo! "apt-get install -y libreadline-dev libpcre3-dev libssl-dev perl patch"
      ssh.sudo! [
        "cd /tmp",
        "mkdir /app",
        "echo 'Downloading OpenResty #{OPENRESTY_STABLE_VERSION}'",
        "wget --progress=dot:mega https://github.com/agentzh/ngx_openresty/tarball/v#{OPENRESTY_STABLE_VERSION} -O #{OPENRESTY_STABLE_VERSION}.tar.gz",
        "tar -zxvf #{OPENRESTY_STABLE_VERSION}.tar.gz",
        "cd `ls | grep agent`",
        "echo 'Building Package'",
        "make",
        "cd `ls | grep ngx_openresty`",
        "echo 'Building OpenResty'",
        "./configure --with-luajit --prefix=/app/openresty/nginx",
        "make",
        "make install",
        "echo 'Building tar'",
        "cd /app",
        "tar -zcvf openresty_nginx-#{OPENRESTY_STABLE_VERSION}.tar.gz openresty"
      ]
    end
  end
end
