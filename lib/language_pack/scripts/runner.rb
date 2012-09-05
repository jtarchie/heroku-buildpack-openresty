#!/usr/bin/env ruby

modified_filename = "nginx-#{Time.now.to_i}.conf"
conf_file = File.read("nginx.conf").gsub!(/\$ENV_(\w+)/) { ENV[$1] }
File.open(modified_filename, "w") {|f| f.puts conf_file }
%x{nginx -c \`pwd\`/#{modified_filename} -g "daemon off;"}