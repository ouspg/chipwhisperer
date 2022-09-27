 # https://github.com/newaetech/chipwhisperer-vagrant/blob/4485766ac6648e18d1bdca8f1856d23504a9b0fb/Vagrantfile
 Vagrant.configure("2") do |config|
  config.vm.box = "generic/alpine316"
  config.vm.network "forwarded_port", guest: 8888, host: 8888
  
  config.vm.provision "file", source: "run.sh", destination: "/home/vagrant/run.sh"
  config.vm.provision "file", source: "jupyter_notebook_config.py", destination: "/home/vagrant/.jupyter/jupyter_notebook_config.py"
  config.vm.provision "shell", path: "setup.sh", env: {"REPO_URL" => ENV['REPO_URL']}
  
  # config.vm.provision "shell", inline: "DEBIAN_FRONTEND=noninteractive apt-get install make; DEBIAN_FRONTEND=noninteractive make"
  
  config.vm.provider "virtualbox" do |vb|
    vb.customize ["modifyvm", :id, "--usb", "on"]
    vb.customize ["modifyvm", :id, "--usbxhci", "on"]
    #manually turn off USB1, otherwise still enabled
    vb.customize ["modifyvm", :id, "--usbohci", "off"]
    vb.gui = true
    vb.name = "ChipWhisperer CompSec Jupyter"
    vb.customize ["modifyvm", :id, "--uartmode1", "disconnected"]
    vb.customize ['usbfilter', 'add', '0', '--target', :id, '--name', 'NewAE Technology Inc. ChipWhisperer Lite [0100]', '--vendorid', '0x2b3e', '--productid', '0xace2']
    vb.customize ['usbfilter', 'add', '0', '--target', :id, '--name', 'ATSAM Booloader', '--vendorid', '03EB', '--productid', '6124']
    vb.customize ['usbfilter', 'add', '1', '--target', :id, '--name', 'NewAE Technology Inc. ChipWhisperer Nano [0100]', '--vendorid', '0x2b3e', '--productid', '0xace0']
    vb.customize ['usbfilter', 'add', '2', '--target', :id, '--name', 'NewAE Technology Inc. ChipWhisperer Pro [0100]', '--vendorid', '0x2b3e', '--productid', '0xace3']
    vb.customize ['usbfilter', 'add', '2', '--target', :id, '--name', 'NewAE Technology Inc. ChipWhisperer CW305', '--vendorid', '0x2b3e', '--productid', '0xc305']
    vb.customize ['usbfilter', 'add', '2', '--target', :id, '--name', 'NewAE Technology Inc. Ballistic Gel', '--vendorid', '0x2b3e', '--productid', '0xc521']
    vb.customize ['usbfilter', 'add', '2', '--target', :id, '--name', 'NewAE Technology Inc. PhyWhisperer', '--vendorid', '0x2b3e', '--productid', '0xC610']
    vb.memory = "4096"
  end
end