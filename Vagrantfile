# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure("2") do |config|

  config.vm.box         = "bento/ubuntu-22.04"
  config.vm.box_version = ">=202407.23.0"
  config.vm.hostname    = "k8s-lab"

  config.vm.network "private_network", ip: "192.168.56.10"

  config.vm.provider "virtualbox" do |vb|
    vb.name   = "k8s-lab"
    vb.memory = 6144
    vb.cpus   = 2
    vb.customize ["modifyvm", :id, "--natdnshostresolver1", "on"] # enable NAT DNS host resolver for better hostname resolution
    vb.customize ["modifyvm", :id, "--ioapic", "on"] # enable IO APIC for better performance and stability with modern OSes
  end

  config.vm.provision "shell" do |s|
    ssh_pub_key = File.read(File.expand_path("~/.ssh/k8s_lab_key.pub")).strip
    s.inline = <<-SHELL
      echo "#{ssh_pub_key}" >> /home/vagrant/.ssh/authorized_keys
      chmod 600 /home/vagrant/.ssh/authorized_keys
      chown vagrant:vagrant /home/vagrant/.ssh/authorized_keys
    SHELL
  end

  config.vm.provision "shell" do |s|
    s.inline = <<-SHELL
      apt-get update -qq
      apt-get install -y -qq curl

      curl -sfL https://get.k3s.io | sh -s - \
        --write-kubeconfig-mode 644 \
        --tls-san 192.168.56.10 \
        --node-external-ip 192.168.56.10

      echo "Waiting for k3s node to be ready..."
      until kubectl get nodes 2>/dev/null | grep -q " Ready"; do
        sleep 3
      done
      echo "Node is Ready."

      cp /etc/rancher/k3s/k3s.yaml /vagrant/kubeconfig.yaml
      sed -i 's/127.0.0.1/192.168.56.10/g' /vagrant/kubeconfig.yaml

      echo "kubeconfig written to /vagrant/kubeconfig.yaml"
      echo "On your host, run: export KUBECONFIG=$(pwd)/kubeconfig.yaml"
    SHELL
  end

end