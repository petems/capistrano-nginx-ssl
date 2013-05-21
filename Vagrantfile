Vagrant::Config.run do |config|
  config.vm.box = "UbuntuServer12.04amd64.box"

  config.vm.box_url = "http://goo.gl/8kWkm"

  guest_address = '192.168.30.15'
  warn "Guest VM will listen on #{guest_address}"
  config.ssh.forward_agent = true
  config.vm.network :hostonly, guest_address
  config.vm.provision :shell, :path => "vagrant.sh"
end
