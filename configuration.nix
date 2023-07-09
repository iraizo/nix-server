# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running `nixos-help`).

{ inputs, config, pkgs, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
    ];
  
  nix.settings.extra-experimental-features = [ "flakes" "nix-command" ];

  # time to get ipv6 working
  security.wrappers.traceroute = {
    owner = "root";
    group = "root";
    capabilities = "cap_net_raw=eip";
    source = "${pkgs.traceroute.out}/bin/traceroute";
  };

  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  
  networking.hostName = "nixos-homeserver"; # Define your hostname.
  networking.networkmanager.enable = true;  # Easiest to use and most distros use this by default.

  # Set your time zone.
  time.timeZone = "Europe/Berlin";
  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.raizo = {
    isNormalUser = true;
    extraGroups = [ "wheel" "docker" ]; # Enable ‘sudo’ for the user.
    packages = with pkgs; [];
    openssh.authorizedKeys.keys = ["ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIPu4/uGwtSL6MMdcneGnneF3mVli/2I+bbIrkydrg6+9 admin@raizo.dev"];
    shell = pkgs.fish;
  };

  # fish shell
  programs.fish.enable = true;

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    vim # Do not forget to add an editor to edit configuration.nix! The Nano editor is also installed by default.
    wget
    traceroute
    git
  ];

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  programs.mtr.enable = true;
  programs.gnupg.agent = {
    enable = true;
    enableSSHSupport = true;
  };

  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  services.openssh.enable = true;

  # password manager
  services.vaultwarden.enable = false;
  services.vaultwarden.config = {
	DOMAIN = "https://vault.raizo.dev";
	SIGNUPS_ALLOWED = true;
	ROCKET_ADDRESS = "127.0.0.1";
  	ROCKET_PORT = 8222;
	ROCKET_LOG = "critical";
  };
    
  # grafana dashboard
  services.grafana = { 
        enable = true;
        settings = {
            server = {
                http_addr = "127.0.0.1";
                http_port = 80;
            };
        };
  };


  services.caddy.enable = false;
  services.caddy.virtualHosts."http://vault.raizo.dev" = {
	extraConfig = ''
		encode gzip
		reverse_proxy 127.0.0.1:8222 {
			header_up X-Real-IP {remote_host}
		}
	'';
  };

  # media server
  services.jellyfin.enable = true;

  # vpn 
  services.mullvad-vpn.enable = true;

  # torrenting
  services.aria2.enable = true;
  services.aria2.extraArguments = "--interface=wg-mullvad";

  services.sonarr.enable = true;
  services.radarr.enable = true;
  services.prowlarr.enable = true;

  # other media
  services.vsftpd = {
    enable = true;
    writeEnable = true;
    localUsers = true;
    userlist = ["raizo"];
    userlistEnable = true;
    localRoot = "/media/hdd/";

    extraConfig = ''
        pasv_enable=Yes
        pasv_min_port=5000
        pasv_max_port=5005
    '';
  };

 
  # Open ports in the firewall.
  networking.firewall.allowedTCPPorts = [80 8096 8989 7878 21];
  networking.firewall.allowedTCPPortRanges = [{ from = 5000; to = 5005; }];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

  # Copy the NixOS configuration file and link it from the resulting system
  # (/run/current-system/configuration.nix). This is useful in case you
  # accidentally delete configuration.nix.
  # system.copySystemConfiguration = true;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It's perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "23.11"; # Did you read the comment?

}
