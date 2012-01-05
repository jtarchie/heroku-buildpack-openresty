bundle exec vagrant up
mkdir ../build
scp -P 2222 vagrant@localhost:/app/openresty_nginx-*.tar.gz ../build
bundle exec vagrant destroy
