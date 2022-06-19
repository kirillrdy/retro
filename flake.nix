{
  description = "retro";
  outputs = { self, nixpkgs }:
    {
      nixosConfigurations =
        let
          pkgs = import nixpkgs { system = "x86_64-linux"; };
          startX = pkgs.writeShellScriptBin "run" ''
            echo exec $@ > ~/.xinitrc
            startx
          '';
          simplesystem = { hostName, enableNvidia ? false, rootPool ? "zroot/root", bootDevice ? "/dev/nvme0n1p3", dwm ? false }: {
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
                  nix = {
                    extraOptions = ''
                      experimental-features = nix-command flakes
                    '';
                  };


                  nixpkgs.config.allowUnfree = true;
                  boot.loader.systemd-boot.enable = true;
                  boot.loader.efi.canTouchEfiVariables = true;

                  networking.hostId = "00000000";
                  networking.hostName = hostName;
                  time.timeZone = "Europe/Kiev";

                  i18n.defaultLocale = "cp866";
                  services.xserver.displayManager.startx.enable = !dwm;
                  services.xserver.displayManager.autoLogin.user = "retro";
                  services.xserver.enable = true;
                  services.xserver.videoDrivers = [ "modesetting" ];
                  services.xserver.windowManager.dwm.enable = dwm;

                  environment.systemPackages = with pkgs; [
                    dmenu
                    xmoto
                    neovim
                    wineWowPackages.full
                    far2l
                    mc
                    firefox
                    startX
                  ];
                  users.users.retro = {
                    isNormalUser = true;
                    password = "jnlehfrjd";
                    extraGroups = [ "wheel" ];
                  };
                  networking.firewall.enable = false;
                  system.stateVersion = "22.05";
                })
            ];
          };
        in
        {
          retro1 = nixpkgs.lib.nixosSystem (simplesystem { hostName = "retro1"; });
          retro2 = nixpkgs.lib.nixosSystem (simplesystem { hostName = "retro2"; dwm = true; });
        };
    };
}
