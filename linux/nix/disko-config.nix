{ targetDisk ? "/dev/sda", withSwap ? false, swapSize ? "16G", filesystem ? "ext4", ... }:

let
  rootContent =
    if filesystem == "btrfs" then {
      type = "btrfs";
      extraArgs = [ "-f" ];
      subvolumes = {
        "@root" = {
          mountpoint = "/";
          mountOptions = [ "compress=zstd" "noatime" ];
        };
        "@home" = {
          mountpoint = "/home";
          mountOptions = [ "compress=zstd" "noatime" ];
        };
        "@nix" = {
          mountpoint = "/nix";
          mountOptions = [ "compress=zstd" "noatime" ];
        };
        "@snapshots" = {
          mountpoint = "/.snapshots";
          mountOptions = [ "compress=zstd" "noatime" ];
        };
      };
    } else {
      type = "filesystem";
      format = "ext4";
      mountpoint = "/";
    };

  partitions = {
    ESP = {
      priority = 1;
      type = "EF00";
      size = "500M";
      content = {
        type = "filesystem";
        format = "vfat";
        mountpoint = "/boot";
        mountOptions = [ "umask=0077" ];
      };
    };

    root = {
      priority = 3;
      size = "100%";
      content = rootContent;
    };
  } // (if withSwap then {
    swap = {
      priority = 2;
      type = "8200";
      size = swapSize;
      content = {
        type = "swap";
        resumeDevice = true;
      };
    };
  } else {});
in
{
  disko.devices = {
    disk = {
      my-disk = {
        device = targetDisk;
        type = "disk";
        content = {
          type = "gpt";
          inherit partitions;
        };
      };
    };
  };
}
