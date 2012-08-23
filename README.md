# Mina + Rails + Unicorn + nginx + God
============================

An example deployment configuration using [Mina](https://github.com/nadarei/mina) for deployment.

Deploys and updates Rails application and config files for [Unicorn](http://unicorn.bogomips.org/), [nginx](http://wiki.nginx.org/Main), and [God](http://godrb.com/).

Why
---

When I've started using Mina for deployment, these examples was the thing I needed most.

Not to just copy and use, but also to read and understand.

After a few days of tinkering I've came up with this setup.

So I thought, why not share? I hope it can be useful for somebody, so that one can see, learn, understand, and use.

How
---

This example assumes following:

* you're running Ubuntu in Vagrant locally (quite nice tool I'd say. Check out [RBates Railscast](http://railscasts.com/episodes/292-virtual-machines-with-vagrant) on this subject)
* you already have a user, that will be running deployment and all the server stuff
* this user have sudo privileges OR you have a separate user that have sudo privileges. You'll need sudoer for setup_extras and config:link tasks. If you don't have separate sudoer, script will assume that deployer have all the necessary sudo rights. If you know workaround, please, let me know about it!
* you already installed and configured git, rvm (global installation preferred) and nginx, at least
* probably something else I forgot at the moment. Don't expect flawless deploy from scratch anyway

Example deployment to local vagrant virtual machine:
```bash
# copy config/deploy.rb to $YOUR_APP/config/deploy.rb
# copy lib/mina to $YOUR_APP/lib
# edit common settings and anything you like in config/deploy.rb
# edit lib/mina/servers/vagrant.rb to match your server configuration
mina vagrant init
mina vagrant setup
mina vagrant setup_extras
mina vagrant god:setup
mina vagrant nginx:setup    # needs sudo. see lib/mina/nginx.rb:10
mina vagrant config:upload
mina vagrant config:link    # needs sudo to copy god and unicorn service control scripts
mina vagrant deploy
mina vagrant nginx:restart  # or nginx:start
mina vagrant god:start      # it will also run unicorn automagically
```
You should be up and running now. Yay!

What now?

You can check God status:

    mina vagrant god:status

...or overall processes status/health:

    mina vagrant health

You can customize output of this command in lib/mina/extras.rb:33

Just make sure you have no bash zombies, running around, eating your CPU. Just in case...

To deploy next release, just run

    mina vagrant deploy

If you've changed some of the config files for god/unicorn/nginx, you can upload them to server with `mina vagrant config:upload`.

If changed code includes unicorn or god control script (service), you will also need to run `mina vagrant config:link`, which require sudo privileges. Keep in mind, that any nginx controlling task also requires sudo! Those are: stop, start, restart, reload, and status.

Individual tasks also available, like `god:upload`, or `unicorn:link`.

You can also run `mina vagrant god:parse:unicorn` to see how god's unicorn config file will look like without uploading it to server. Very useful for debugging!

Just check out task files under lib/mina directory, most of the code there is quite self-explanatory!
    
This code sucks
---------------

Well, most probably it is. But it is the code I'm currently using for production deployment, and if you think you can improve
it or just have a better idea regarding anything described here - just send me an email or pull request.

Me
--

[Github](https://github.com/alfuken)

[Blog](http://alfuken.tumblr.com/)

[Twitter](http://twitter.com/alfuken)
