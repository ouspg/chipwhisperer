
# Reduced ChipWhisperer environment repo for CW303 and CWNANO 



## Usage

The image expects that the ChipWhisperer device is correctly configured on the host Linux machine.
This means, that `udev` rules have been correctly applied, as described in he file [50-newae.rules.](50-newae.rules)
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
We could use these inside the container if we ran the container as as privileged, but we will avoid that.

> The group ID must be the same in the container as in the host system for non-root user to work.

Currently, gid is `1999` in the container.  

To set `udev` correctly, c



For running the container, use:

```console
docker run -it --rm  --device=/dev/bus/usb:/dev/bus/usb -p 8888:8888 --name cwtest ghcr.io/ouspg/chipwhisperer:latest

```

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