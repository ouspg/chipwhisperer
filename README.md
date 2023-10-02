
# Reduced ChipWhisperer environment repo for CW303 and CWNANO 

Configuration and build files for OCI-based ChipWhisperer environment image, which supports CW303 and CWNANO devices. 

## Usage

The environment requires access into the ChipWhisperer device, which is located in `/dev/bus/usb/`.
By default, regular user probably does not have enough permissions to use it.

Permissions can be obtained in few ways without making them too board:

1. Temporally by chown'ing the correct device from `/dev/bus/usb/` to reflect desired UID:GID
2. Permanently by modifying `udev` rules

To find the correct bus, you could use command `lsusb` (requires USB metadata package to show more details).
`2b3e` is vendor ID of ChipWhisperer.

```console
14c6ede0c643:/home/appuser# lsusb
Bus 004 Device 001: ID 1d6b:0003 Linux 6.2.10-1-aarch64-ARCH xhci-hcd xHCI Host Controller
Bus 001 Device 002: ID 2b3e:ace0 NewAE Technology Inc. ChipWhisperer Nano 
```

Then give permissions for the desired user. 
```console
chown appuser:appuser /dev/bus/usb/001/002
```
If you want to give these permissions for the container user after starting it, you can `exec` into it:
```console
docker exec -it --user=root cwtest bash
```
And do the previous.


Alternatively, we can correctly configure the host Linux machine to use `udev` rules, which will reflect the container as well.
This means, that `udev` rules have been applied, as described in he file [50-newae.rules.](50-newae.rules)
Copy it as:

```console
sudo cp 50-newae.rules /etc/udev/rules.d/
```
Create group `chipwhisperer` and add it to your user

```console
sudo groupadd -g 1999 chipwhisperer
sudo usermod -aG $USER
```

Now, you will need to reboot.


These rules will set correct group permission (of group `chipwhisperer`) for the devices when they appear in `/dev/bus/usb` directory.
We could use `udev` rules inside the container as well if we ran the container as as privileged, but we will avoid that.

> **Note**
> The group ID must be the same in the container as in the host system for non-root user to work.

Currently, gid is `1999` in the container.  

To set `udev` correctly, c



For running the container, use:

```console
docker run -it --rm  --device=/dev/bus/usb:/dev/bus/usb -p 8888:8888 --name cwtest ghcr.io/ouspg/chipwhisperer:latest
```

You can find jupyter notebooks from `localhost:8888`, and the password is `jupyter`.


## Building

Using Buildx to build multi-arch:
```console
docker buildx build  --push --platform linux/amd64,linux/arm64 -t ghcr.io/ouspg/chipwhisperer --build-arg="NOTEBOOK_PASS=jupyter"
```

## Debugging

Set entrypoint as `--entrypoint=/bin/bash` when running the container.


To quickly test that the device in the container is working, run the following.
It should not print anything, expect warning about outdated firmware, if the device is working.

```console
python -c 'import chipwhisperer as cw; scope = cw.scope();'
```