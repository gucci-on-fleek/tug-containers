`containers`
============

This user was created to host rootless Podman containers. The easiest
way to see a list of the “important” files is to run

```console
$ git ls-files
```

Commands
--------

### General

You _should_ be able to run

```console
$ sudo systemctl --user --machine=containers@ <command>
```

as any (`wheel`ed) user to control the containers, but this doesn't work
for some reason. Instead, you'll need to use the more cumbersome

```console
$ sudo -u containers sh -c "XDG_RUNTIME_DIR=/run/user/$(id -u) systemctl --user <command>"
```

or log in as `containers` and run

```console
$ export XDG_RUNTIME_DIR=/run/user/$(id -u)
$ systemctl --user <command>
```

(If you don't do this, you'll get a `Failed to connect to bus` error.)

### Starting/stopping the container

```console
$ systemctl --user start viewvc.service
$ systemctl --user stop viewvc.service
```

### Restarting the container

```console
$ systemctl --user daemon-reload  # To reload the unit file
$ systemctl --user restart viewvc.service
```

### Committing updates to any files

```console
$ git add -A && git commit && git push
```

### Let the container access the certificates

```console
sudo chmod a+X /etc/dehydrated/
sudo chmod a+X /etc/dehydrated/certs/
sudo chgrp -R containers /etc/dehydrated/certs/svn.tug.org/
sudo chmod -R g+rX /etc/dehydrated/certs/svn.tug.org
sudo setfacl -R -m u:101000:r /etc/dehydrated/certs/svn.tug.org/
sudo setfacl -m u:101000:rx /etc/dehydrated/certs/svn.tug.org/
```

### Weird “Access Denied” errors as `containers`

If you get “Access Denied” errors when trying to access files in
`~containers` while logged-in as `containers`, you might need to switch
to the Podman user namespace:

```console
podman unshare /bin/bash
```

Files
-----

### General

I've added `mseven` and `karl` to the `containers` group, and ran `chmod
-R g+rws` on `~containers`, so you should generally be able to modify
and view all these files fairly easily.

### `.config/containers/systemd/viewvc.container`

This contains the Podman Quadlet systemd unit file for the `viewvc`
container. If you're familiar with Docker, this is almost the same thing
as a `docker-compose.yml` file. Essentially, this file specifies how
systemd and Podman should run the specified container. You can read more
about this in [`man 5
podman-systemd.unit`](https://docs.podman.io/en/latest/markdown/podman-systemd.unit.5.html).

More specifically, this file specifies where to find the container
image, what volumes to mount, and when to start the container. You can
view the source for the `viewvc` container image
[here](https://github.com/gucci-on-fleek/maxchernoff.ca/tree/master/builder/containers/viewvc).

### `viewvc/Caddyfile`

This is the configuration file for the Caddy web server. This is placed
in front of the ViewVC server to handle TLS termination, caching, and
rate limitting. You can read more documentation about this
[here](https://caddyserver.com/docs/).

### `viewvc/viewvc.conf`

This is the configuration file for the ViewVC server. I mostly just
copied this from the one that Karl used for the original server.

### `viewvc/data/`

This folder contains miscellaneous data created by the container. None
of these files should need to be modified directly, but the container
needs them to persist between restarts.

### `viewvc/data/caddy-log/*.log`

These are the request logs for the Caddy web server, which are probably
the only interesting thing in `viewvc/data/`.

### `.config/systemd/user/podman-auto-update.timer.d/override.conf`

This file configures systemd to automatically update and restart all the
containers once per week. Max's server automatically rebuilds all the
container images daily, and this pulls updates from there.
