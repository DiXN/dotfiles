{ targetDisk ? "/dev/sda", ... }:
{
  disko.devices = {
    disk = {
      my-disk = {
        device = targetDisk;
        type = "disk";
        content = {
          type = "gpt";
          partitions = {
            ESP = {
              type = "EF00";
              size = "500M";
              content = {
                type = "filesystem";
                format = "vfat";
                mountpoint = "/boot";
                mountOptions = [ "umask=0077" ];
              };
            };
            primary = {
              size = "100%";  # Use all remaining space for LVM
              content = {
                type = "lvm_pv";
                vg = "mainpool";
              };
            };
          };
        };
      };
    };
    lvm_vg = {
      mainpool = {
        type = "lvm_vg";
        lvs = {
          thinpool = {
            size = "95%";
            lvm_type = "thin-pool";
          };
          home = {
            size = "10G";
            lvm_type = "thinlv";
            pool = "thinpool";
            content = {
              type = "filesystem";
              format = "ext4";
              mountpoint = "/home";
            };
          };
          nix = {
            size = "10G";
            lvm_type = "thinlv";
            pool = "thinpool";
            content = {
              type = "filesystem";
              format = "ext4";
              mountpoint = "/nix";
              mountOptions = [ "noatime" ];  # Reduce writes--we don't care about access times
            };
          };
          root = {
            size = "10G";
            lvm_type = "thinlv";
            pool = "thinpool";
            content = {
              type = "filesystem";
              format = "ext4";
              mountpoint = "/";
              mountOptions = [ "defaults" ];
            };
          };
        };
      };
    };
  };
}
