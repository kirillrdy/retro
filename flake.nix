{
  description = "retro";
  inputs.nixpkgs.url = "github:nixos/nixpkgs";
  outputs = { self, nixpkgs }:
    {
      nixosConfigurations =
        let
          simplesystem = { hostName, enableNvidia ? false, rootPool ? "zroot/root", bootDevice ? "/dev/nvme0n1p3", swapDevice ? "/dev/nvme0n1p2" }: {
            system = "x86_64-linux";
            modules = [
              ({ pkgs, lib, modulesPath, ... }:
                {
                  imports =
                    [
                      (modulesPath + "/installer/scan/not-detected.nix")
                      "${nixpkgs}/nixos/modules/virtualisation/qemu-vm.nix"
                    ];

                  #virtualisation.memorySize = 8000;
                  #virtualisation.cores = 8;
                  virtualisation.diskSize = 1024 * 10;

                  boot.initrd.availableKernelModules = [ "nvme" ];
                  fileSystems."/" = { device = rootPool; fsType = "zfs"; };
                  fileSystems."/boot" = { device = bootDevice; fsType = "vfat"; };
                  swapDevices = [{ device = swapDevice; }];
                  nix = {
                    extraOptions = ''
                      experimental-features = nix-command flakes
                    '';
                  };


                  nixpkgs.config.allowUnfree = true;
                  boot.loader.systemd-boot.enable = true;
                  boot.loader.efi.canTouchEfiVariables = true;
                  boot.kernelPackages = pkgs.linuxPackages_5_17;

                  networking.hostId = "00000000";
                  networking.hostName = hostName;
                  time.timeZone = "Australia/Melbourne";

                  i18n.defaultLocale = "en_AU.UTF-8";
                  services.xserver.displayManager.autoLogin.enable = true;
                  services.xserver.displayManager.autoLogin.user = "retro";
                  services.xserver.enable = true;
                  services.xserver.videoDrivers = [ "modesetting" ];

                  services.xserver.windowManager.dwm.enable = true;

                  environment.systemPackages = with pkgs; [
                    dmenu
                    xmoto
                    neovim
                    wineWowPackages.full
                    far2l
                    mc
                  ];
                  users.users.retro = {
                    isNormalUser = true;
                    password = "jnlehfrjd";
                    extraGroups = [ "wheel" "docker" "vboxusers" ];
                  };
                  networking.firewall.enable = false;
                  system.stateVersion = "21.11"; # Did you read the comment?
                })
            ];
          };
        in
        {
          retro = nixpkgs.lib.nixosSystem (simplesystem { hostName = "retro"; });
        };
    };
}
