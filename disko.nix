# USAGE in your configuration.nix.
# Update devices to match your hardware.
{
 imports = [ ./disko-config.nix ];
 disko.devices.disk.main.device = "/dev/disk/by-id/sdanvme-Vi3000_Internal_PCIe_NVMe_M.2_SSD_256GB_493734484830052";
# ata-ST14000NM005G-2KG133_ZL2HVF8F
# ata-ST14000NM005G-2KG133_ZL2HXWBS
# ata-ST14000NM005G-2KG133_ZL2K6NBN
# ata-ST14000NM005G-2KG133_ZTM0A0Q0

}
{
  disko.devices = {
    disk = {
      main = {
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
            root = {
              size = "100%";
              content = {
                type = "filesystem";
                format = "ext4";
                mountpoint = "/";
              };
            };
          };
        };
      };
    };
  };
}