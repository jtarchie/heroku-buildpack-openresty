#!/usr/bin/env ruby

reqruie 'uri'

if ENV['DATABASE_URL']
  database_url = URI.parse(ENV['DATABASE_URL'])
  ENV['DB_HOST'] = database_url.host
  ENV['DB_NAME'] = database_url.path.sub(/^\//,'')
  ENV['DB_USERNAME'] = database_url.user
  ENV['DB_PASSWORD'] = database_url.password
end

modified_filename = "nginx-#{Time.now.to_i}.conf"
conf_file = File.read("nginx.conf").gsub!(/\$ENV_(\w+)/) { ENV[$1] }
File.open(modified_filename, "w") {|f| f.puts conf_file }
%x{nginx -c \`pwd\`/#{modified_filename} -g "daemon off;"}