Vagrant.configure("2") do |config|

  # Configure Jenkins
  config.vm.define "jenkins" do |jenkins|
    jenkins.vm.box = "bento/ubuntu-22.04"
    jenkins.vm.hostname = "jenkins-server"
    jenkins.vm.provider "vmware_desktop" do |vb|
      # vb.gui = true
      vb.cpus = '4'
      vb.memory = '6208'
    end
    jenkins.vm.network "private_network", ip: "10.0.0.10"
    jenkins.vm.network "public_network", ip: "192.168.1.24", bridge: "Wi-Fi 2"
    jenkins.vm.provision "shell", path: "jenkins.sh"
  end

 # Configure sonarqube
  config.vm.define "sonarqube" do |sonarqube|
    sonarqube.vm.box = "bento/ubuntu-22.04"
    sonarqube.vm.hostname = "sonarqube-server"
    sonarqube.vm.provider "vmware_desktop" do |vb|
      # vb.gui = true
      vb.cpus = '4'
      vb.memory = '4096'
    end
    sonarqube.vm.network "private_network", ip: "10.0.0.11"
    sonarqube.vm.network "public_network", ip: "192.168.1.25", bridge: "Wi-Fi 2"
    sonarqube.vm.provision "shell", path: "sonarqube.sh"
  end

  # Configure nexus
  config.vm.define "nexus" do |nexus|
    nexus.vm.box = "bento/ubuntu-22.04"
    nexus.vm.hostname = "nexus-server"
    nexus.vm.provider "vmware_desktop" do |vb|
        # vb.gui = true
        vb.cpus = '4'
        vb.memory = '4096'
    end
    nexus.vm.network "private_network", ip: "10.0.0.12"
    nexus.vm.network "public_network", ip: "192.168.1.26", bridge: "Wi-Fi 2"
    nexus.vm.provision "shell", path: "nexus.sh"
  end

  # Configure monitoring
  config.vm.define "monitoring" do |monitoring|
    monitoring.vm.box = "bento/ubuntu-22.04"
    monitoring.vm.hostname = "monitoring-server"
    monitoring.vm.provider "vmware_desktop" do |vb|
        # vb.gui = true
        vb.cpus = '4'
        vb.memory = '4096'
    end
    monitoring.vm.network "private_network", ip: "10.0.0.13"
    monitoring.vm.network "public_network", ip: "192.168.1.27", bridge: "Wi-Fi 2"
    monitoring.vm.provision "shell", path: "monitoring.sh"
  end

end
