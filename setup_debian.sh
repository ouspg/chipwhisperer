#!/usr/bin/env bash
# https://github.com/newaetech/chipwhisperer-vagrant/blob/4485766ac6648e18d1bdca8f1856d23504a9b0fb/setup.sh

# packages
apt-get update
apt-get install --no-install-recommends -y keyboard-configuration
sed 's XKBLAYOUT=\"\w*" XKBLAYOUT=\"fi\" g' -i /etc/default/keyboard
apt-get install --no-install-recommends -y ca-certificates gcc-avr avr-libc gcc-arm-none-eabi
apt-get install --no-install-recommends -y python3 python3-dev python3-pip python3-wheel git make nano libusb-dev libmpfr-dev libgmp-dev libmpc-dev libusb-1.0-0

# repo
git clone --depth=1 $REPO_URL chipwhisperer
cd chipwhisperer

# files
mkdir -p /home/vagrant/.jupyter
cp run.sh /home/vagrant/run.sh
cp jupyter_notebook_config.py /home/vagrant/.jupyter/
chmod +x /home/vagrant/run.sh
chown vagrant:vagrant -R /home/vagrant/

# cron
echo "@reboot /home/vagrant/run.sh" | crontab -u vagrant -

# usb
cp *-newae.rules /etc/udev/rules.d/
addgroup vagrant plugdev
addgroup vagrant dialout
udevadm control --reload-rules

# START
sudo --preserve-env=NOTEBOOK_PASS -Hu vagrant bash <<EOF

# git
git config --global user.name "example"
git config --global user.email "example@example.com"

# setup python
python3 -m pip install --upgrade pip
pi3 install libusb1
pip3 install --no-warn-script-location -r requirements.txt

# setup jupyter
export PATH="/home/vagrant/.local/bin:$PATH"
jupyter contrib nbextension install --user
jupyter nbextensions_configurator enable --user
jupyter nbextension enable toc2/main
jupyter nbextension enable collapsible_headings/main

# jupyter password
python3 -c "import os; from notebook.auth import passwd; print('\nc.NotebookApp.password=\'' + passwd(os.getenv('NOTEBOOK_PASS')) + '\'')" >> /home/vagrant/.jupyter/jupyter_notebook_config.py

# END
EOF

# done
usermod --password $(echo vagrant | openssl passwd -1 -stdin) vagrant
reboot