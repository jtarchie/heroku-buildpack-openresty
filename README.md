# Heroku buildpack: OpenResty Nginx

This is a [Heroku buildpack](http://devcenter.heroku.com/articles/buildpack) for OpenResty application. It will allow the deployment of Nginx Conf files that utilize the extensions that compromise the [OpenResty](http://openresty.org) bundle.

## Usage

Your application is must have a `nginx.conf` file in the root of the application. The buildpack looks for this file to know that it should deploy to Herkou with the OpenResty environment.

    $ ls
    nginx.conf

    $ heroku create --stack cedar --buildpack https://github.com/jtarchie/heroku-buildpack-openresty.git
    Creating young-window-2471... done, stack is cedar
    http://young-window-2471.herokuapp.com/ | git@heroku.com:young-window-2471.git
    Git remote heroku added

    $ git push heroku master
    Counting objects: 10, done.
    Delta compression using up to 2 threads.
    Compressing objects: 100% (7/7), done.
    Writing objects: 100% (10/10), 953 bytes, done.
    Total 10 (delta 2), reused 0 (delta 0)

    -----> Heroku receiving push
    -----> Fetching custom buildpack... done
    -----> Nginx app detected
    -----> Discovering process types
           Procfile declares types -> (none)
           Default types for Nginx -> web
    -----> Compiled slug size is 4.6MB
    -----> Launching... done, v6
           http://young-window-2471.herokuapp.com deployed to Heroku

    To git@heroku.com:young-window-2471.git
     * [new branch]      master -> master

    $ heroku open

### Supported OpenResty Versions

You can specify which version of OpenResty to use when using the buildpack. You can use older stable versions if you need to.

    $ heroku config:add OPENRESTY_VERSION=x.x.x.x

* 1.0.10.24
* 1.0.10.48
* 1.0.11.28
* 1.0.15.10
* 1.2.1.14

## Deployment Notes

If include a `Procfile`, please keep in mind that a lot of magic happens for the `web` dyno. Keep this line in `Procfile` to support all the useful features provided.

    web: erb nginx.conf > .compiled_nginx.conf && touch logs/access.log logs/error.log && (tail -f -n 0 logs/*.log &) && nginx -p . -g "daemon off;" -c `pwd`/.compiled_nginx.conf'

Since nginx doesn't support passing a port as a command line argument, we have to do some preprocessing to use it in the `nginx.conf`. Wherever you define your `listen` directive use `<%= ENV['PORT'] %>` for the port number.

## Example

Please see the example [here](https://github.com/jtarchie/openresty-example). And follow the [Usage](#Usage) for deployment.

## Nginx compilation

It is actually required to build nginx ahead of time for the Heroku environment. These images are built on a VM image that represents the Heroku run time environment.

I am manually updating the version of OpenResty with the build scripts found in `packager/` directory. It requires to have the vagrant gem install and its dependencies.

    $ cd packager
    $ bundle
    $ ./build.sh

This will take a while to run, but the end result will be a tar file in the `build/` directory. They are currently hosted on S3 with my personal account.

This version of OpenResty is configured with the following options:

    ./configure --with-luajit --prefix=/app/openresty --with-http_postgres_module
    
LuaJIT because it is fast. Postgres because it is the database of choice for Heroku.

Please create an issue if you would like more options to be compiled with OpenResty for this buildpack.

## nginx.conf on load

Some magic happens to the `nginx.conf` when the dyno loads. It get evaluated as [ERB](http://ruby-doc.org/stdlib-1.9.3/libdoc/erb/rdoc/ERB.html), so that dynamic evaluation can happen for the port, other environment variable, etc. __WARNING__ This is not backwards compatible with the old way of handling $ENV variables.

### Requiring PORT

Heroku sets an environment variable `PORT` to pass along to the server. Since `nginx.conf` does not normally evaluate with environment variables a _workaround_ was added to support `nginx.conf` preprocessing for environment variables.

To have a port defined in file, use the following:

    server {
      listen <%= ENV['PORT'] %>;
      # reset of server declaration
    }

### Environment variables

Nginx and OpenResty don't support environment variables in the config file. Heroku uses them extensively to set Database, Memcache, and other add-on credentials.

On runtime of the `web` dyno, the `nginx.conf` can

For example, in a `nginx.conf` file far away:

    location /path {
      echo <%= $ENV['PATH'] %>
    }

Would be replaced with:

    location /path {
      echo /usr/bin:/usr/local
    }

It is up to you to make sure strings are escaped correctly, etc. The escaping of values depends on what Nginx conf setting its for.

### DATABASE_URL

If any DATABASE_URL exists in the environment variables, you can parse it down to useful values to be used in the `upstream`.

The following code parses the DATABASE_URL into useful environment variables for host, username, password, and database name:

	<%
		require "uri"
		if ENV['DATABASE_URL']
		  database_url = URI.parse(ENV['DATABASE_URL'])
		  ENV['DB_HOST'] = database_url.host
		  ENV['DB_NAME'] = database_url.path.sub(/^\//,'')
		  ENV['DB_USERNAME'] = database_url.user
		  ENV['DB_PASSWORD'] = database_url.password
		end
	%>

## TODO

* Support for more OpenResty extensions -- Drizzle, Iconv.
* LuaRocks with slug compilation.
* Make it easier to use locally, especially with environment variables.
