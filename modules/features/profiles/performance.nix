_: {
  aspects.performance.nixos = {lib, ...}: {
    boot.kernel.sysctl = {
      "net.core.netdev_max_backlog" = lib.mkDefault 16384;
      "net.core.somaxconn" = lib.mkDefault 8192;
      "net.core.rmem_default" = lib.mkDefault 1048576;
      "net.core.rmem_max" = lib.mkDefault 16777216;
      "net.core.wmem_default" = lib.mkDefault 1048576;
      "net.core.wmem_max" = lib.mkDefault 16777216;
      "net.ipv4.tcp_rmem" = lib.mkDefault "4096 1048576 2097152";
      "net.ipv4.tcp_wmem" = lib.mkDefault "4096 65536 16777216";
      "net.ipv4.tcp_fastopen" = lib.mkDefault 3;
    };

    zramSwap = {
      enable = lib.mkDefault true;
      algorithm = lib.mkDefault "zstd";
      memoryPercent = lib.mkDefault 50;
    };

    nix.daemonCPUSchedPolicy = lib.mkDefault "batch";
    nix.daemonIOSchedClass = lib.mkDefault "idle";
    nix.daemonIOSchedPriority = lib.mkDefault 7;
  };
}
