# Introduction

This is my personal NixOS configuration, that configures multiple devices simultaneously, to be
able to share all my development tools across all desktop environments, and to also be able to
share some core system settings & utilities across all my devices.

# Installation

## Configuration

Install NixOS. The `nixos-generate-config` command will usually generate hardware
specific configuration into `hardware-configuration.nix`.
The hardware configuration is placed somewhere else in this repo, so once the configuration files
have been generated, put the hardware specific configurations in `devices/{name}/hardware.nix`.

You need to add a `device.nix` file in `/etc/nixos` to specify the name of the device, so that the
configuration can finally enable the hardware specific settings.
You can copy `device.nix.example` to `device.nix`.
Then you need to create a `devices/{name}/params.nix` file to further tune in some device
parameters. See the `params.nix` file of other devices for inspiration.
This covers putting the configuration in place.

## Synchronize personal data

If you had put a `syncthingId` in the `params.nix` file, syncthing will be configured to
synchronize all sorts of personal data, including the password store. In order for this to work,
the new device configuration must have been pushed to the repository and pulled onto one of the
other devices as well. Then the synchronization can start happening.

Keep in mind that since the SSH keys have not been installed at this point, you can't push the
configuration changes from the device you are setting up yet. An option would be to `scp` the
configuration to another device.

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

Once the password store is available and accessible, we can put other keys into place. To get the
SSH keys, run the command `install-ssh-keys` as the `bamilab` user. You may still need to run
`ssh-add` as any user to make use of the key.

Now you can also start pushing to this git repo. So within `/etc/nixos`, change the remote url like
so:
```
git remote set-url origin git@github.com:bamidev/nixos-config
```

# Conclusion

Now you should have everything ready to go on the new device: my passwords & keys, my personal files,
and my system and applications configuration.

