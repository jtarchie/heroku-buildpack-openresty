Heroku buildpack: OpenResty Nginx
======================

This is a [Heroku buildpack](http://devcenter.heroku.com/articles/buildpack) for OpenResty application. It will allow the deployment of Nginx Conf files that utilize the extensions that compromise the [OpenResty](http://openresty.org) bundle.

Usage
-----
Your application is meant to have a nginx.conf file in the root of the application. The buildpack looks for this file to know that it should deploy to Herkou with the OpenResty environment.

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

Example
-------

Please see the example [here](https://github.com/jtarchie/openresty-example).
