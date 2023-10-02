
# Reduced ChipWhisperer environment repo for CW303 and CWNANO 



## Usage

The image expects that the ChipWhisperer device is correctly configured on the host Linux machine.
This means, that `udev` rules have been correctly applied, as described in he file [50-newae.rules.](50-newae.rules)

These rules will set correct group permission for the devices when they appear in `/dev/bus/usb` directory.

> The group ID must be the same in the container as in the host system for non-root user to work.

For running the container, use:


```console
docker run -it --rm  --device=/dev/bus/usb:/dev/bus/usb -p 8888:8888 --name cwtest cwsecurity:latest

```


To quickly test that container is working, run the following.
It should not print anything, expect warning about outdated firmware, if the device is working.

```console
python -c 'import chipwhisperer as cw; scope = cw.scope();'
```