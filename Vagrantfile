# -*- mode: ruby -*-
# vi: set ft=ruby :

$IPs = {
  "m1"   => "10.9.8.7",
  "w1"   => "10.9.8.6"
}

def host_check(ips={})
  return ips.map {|k,v|<<-INNER
  if [ ! `grep -q #{v} /etc/hosts` ]; then
    echo '#{v} #{k}' | sudo tee -a /etc/hosts
  fi
  INNER
  }.join()
end

def export_env_and_deploy(ips={}, master="m1", current="w1", nic="eth1")
  return <<-INNER
  export MASTER_IP=#{ips[master]}
  export NET_INTERFACE=#{nic}
  export IP_ADDRESS=#{ips[current]}
  #{case current
    when "m1"
      '/vagrant/kube-deploy/docker-multinode/master.sh'
    when "w1"
      '/vagrant/kube-deploy/docker-multinode/worker.sh'
    end
  }
  INNER
end

Vagrant.configure("2") do |config|
  config.vm.box = "geerlingguy/ubuntu1604"
  config.vm.box_check_update = false
  if Vagrant.has_plugin?("vagrant-cachier")
    config.cache.scope = "box"
    config.cache.synced_folder_opts = {
      type: "nfs",
      mount_options: ['rw', 'vers=3', 'tcp', 'nolock']
    }
  end
  $IPs.map do |k,v|
    config.vm.define "#{k}" do |m|
      m.vm.hostname = "#{k}"
      m.vm.network "private_network", ip: "#{v}"
      m.vm.provision "shell", inline:<<-SHELL
      #{host_check($IPs)}
      SHELL
      m.vm.provision "shell", path: "docker-provision.sh"
      m.vm.provision "shell", path: "pre-k8s.sh"
      m.vm.provision "shell", inline:<<-SHELL
      sudo -s
      cp -f /vagrant/kubectl /usr/local/bin/kubectl
      chmod +x /usr/local/bin/kubectl
      #{export_env_and_deploy($IPs, "m1", k, "eth1")}
      SHELL
    end
  end
end
