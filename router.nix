{ config, pkgs, lib, modulesPath, ... }:

{
  imports = [
    "${modulesPath}/profiles/minimal.nix"
    "${modulesPath}/profiles/qemu-guest.nix"
  ];
  
  # More generic hardware setup that works with nixos-generators
  boot.initrd.availableKernelModules = [ 
    "virtio_pci" 
    "virtio_blk" 
    "virtio_net" 
    "virtio_rng" 
    "virtio_console"
    "9p" 
    "9pnet_virtio"
  ];
  
  # Remove custom module or filesystem options that could cause issues
  boot.initrd.kernelModules = [];
  boot.kernelModules = [];
  boot.extraModulePackages = [];
  
  # Add /mnt/shared mount point (but make it optional)
  fileSystems."/mnt/shared" = {
    fsType = "9p";
    device = "hostshare";
    options = [ "trans=virtio" "version=9p2000.L" "msize=104857600" "nofail" ];
  };
  
  networking = {
    hostName = "router";
    useDHCP = false;
    
    # VLAN configurations
    vlans = {
      vlan10 = {
        id = 10;
        interface = "eth0";
      };
    };
    
    # Interface configurations
    interfaces = {
      eth0 = {
        ipv4.addresses = [{ address = "10.0.10.2"; prefixLength = 24; }];
      };
      vlan10 = {
        ipv4.addresses = [{ address = "10.0.10.2"; prefixLength = 24; }];
      };
    };
    
    # Set default gateway
    defaultGateway = "10.0.10.1";
    firewall.enable = false;
  };
  
  # Enable SSH
  services.openssh.enable = true;
  security.sudo.wheelNeedsPassword = false;
  
  # Create a regular user
  users.users.vlan = {
    isNormalUser = true;
    extraGroups = [ "wheel" ];
    password = "vlan";
  };
  
  # Install useful packages
  environment.systemPackages = with pkgs; [
    vim
    tcpdump
    iperf
    traceroute
    curl
    wget
  ];
  
  # Allow empty passwords for testing
  users.mutableUsers = true;
  services.openssh.settings.PermitRootLogin = "yes";
  services.openssh.settings.PasswordAuthentication = true;
  
  system.stateVersion = "24.11";
}