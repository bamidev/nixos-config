# Introduction

This is my NixOS configuration, that configures multiple devices simultaneously, to be able to
share all the development tools across all desktop environments, and to also be able to share some
core system settings & utilities across all my devices.

# Installation

## Configuration

Install NixOS like normal. The `nixos-generate-config` command will usually generate hardware
specific configuration into `hardware-configuration.nix`. So use that first, and then pull these
configurations into `/etc/nixos`.

You need to add a `config.nix` file to specify some parameters. A template is provided in 
`config.nix.example`, so you can just copy that to `config.nix` and edit it.
This covers the configuration of NixOS.

## Synchronize personal data

To get all my personal data in place, syncthing needs to be configured to know about the new device
that is going to be used. For this, the `apps/syncthing.nix` file needs to be edited to declare the
new device and to add it to all the folders.

So the configuration will now be updated, and it needs to be pulled in on at least the 'home
server' device.
This will make my password store accessible on the new device.

## Keys

### PGP

The next thing to put into place is probably my PGP key. This is also going to be needed to access
the password store. This is a manual action that is not automated. But for reference, here is what
to do when you have the key placed in `my-key.pgp`, as the `bamilab` user:
```
gpg --import my-key.pgp
gpg --list-keys # To check the key id of the just imported key
gpg --edit-key <KEY-ID>
```
In the dialog of the second command, run `trust`, then `5`, and then `save`.
The PGP key should now be imported.

### SSH

All SSH keys are stored in the password store. To put them in place for all users, run the command
`install-ssh-keys` as the `bamilab` user. You may still need to run `ssh-add` as any user to make
use of the key.

Now you can also start pushing to this git repo. So within `/etc/nixos`, change the remote url like
so:
```
git remote set-url origin git@github.com:bamidev/nixos-config
```

# Conclusion

Now I should have everything ready to go on the new device: my passwords & keys, my personal files,
and my system and applications configuration.

