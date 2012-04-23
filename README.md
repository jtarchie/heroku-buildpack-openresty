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
    logs
    -----> Discovering process types
           Procfile declares types -> (none)
           Default types for Nginx -> web
    -----> Compiled slug size is 4.6MB
    -----> Launching... done, v6
           http://young-window-2471.herokuapp.com deployed to Heroku

    To git@heroku.com:young-window-2471.git
     * [new branch]      master -> master

    $ heroku open

## Example

Please see the example [here](https://github.com/jtarchie/openresty-example).

## Nginx compilation

It is actually required to build nginx ahead of time for the Heroku environment. These images are built on a VM image that represents the Heroku run time environment.

I am manually updating the version of OpenResty with the build scripts found in `packager/` directory. It requires to have the vagrant gem install and its dependencies.

    $ cd packager
    $ ./build.sh

This will take a while to run, but the end result will be a tar file in the `build/` directory. They are currently hosted on S3 with my personal account.

## Environment variables

Nginx and OpenResty don't support environment variables in the config file. Heroku uses them extensively to set Database, Memcache, and other add-on credentials.

On runtime of the `web` dyno, the `nginx.conf` replaces all references of variables prepended with `$ENV_` with the environment variable equivalent.

For example:

    nginx.conf
    location /path {
      echo $ENV_PATH
    }

Would be replaced with:

    nginx.conf
    location /path {
      echo /usr/bin:/usr/local
    }

It is up to you to make sure strings are escaped correctly, etc. The escaping of values depends on what Nginx conf setting its for.

## TODO

* Support defined versions of OpenResty when creating slug.
* If the slug already has the current version of OpenResty, don't redownload.
* Support for more OpenResty extensions -- Drizzle, Iconv.
* LuaRocks with slug compilation.
