#!/usr/bin/env bash
# https://github.com/newaetech/chipwhisperer-vagrant/blob/4485766ac6648e18d1bdca8f1856d23504a9b0fb/setup.sh

# packages
apk update
sed 's http: https: ' -i /etc/apk/repositories
sed 's ^#\(https://[^/]*/alpine/v[^/]*/community\)$ \1 ' -i /etc/apk/repositories
apk update
apk add python3 py3-pip git gcc-avr avr-libc gcc-arm-none-eabi make nano udev busybox-initscripts sudo bash

# user
chmod +x /home/vagrant/run.sh
chown vagrant:vagrant -R /home/vagrant/
sudo -Hu vagrant git config --global user.name "example"
sudo -Hu vagrant git config --global user.email "example@example.com"

# repo
git clone --depth=1 $REPO_URL chipwhisperer
cd chipwhisperer

# usb
cp *-newae.rules /etc/udev/rules.d/
usermod -a -G plugdev vagrant
udevadm control --reload-rules

# setup python
sudo -Hu vagrant python3 -m pip install --upgrade pip
sudo -Hu vagrant pip3 install -r requirements.txt

# setup jupyter
jupyter contrib nbextension install --system
jupyter nbextensions_configurator enable --system
sudo -Hu vagrant jupyter nbextension enable toc2/main
sudo -Hu vagrant jupyter nbextension enable collapsible_headings/main

# cron
if !(crontab -u vagrant -l | grep "run\.sh"); then
    (crontab -u vagrant -l 2>/dev/null; echo "@reboot /home/vagrant/run.sh") | crontab -u vagrant -
fi

reboot