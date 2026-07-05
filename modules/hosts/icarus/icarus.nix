{config, ...}: {
  registry.hosts.icarus = {
    username = "icarus";
    system = "x86_64-linux";
    stateVersion = "25.11";
    aspects = with config.flake.lib.aspects; [
      hardwareIcarus
      sshd
      diskoIcarus
      local
      core
      foot
      shell
      session
      greetd
      niri
      noctalia
      fonts
      apps
    ];

    finixModule = _: {
      users.users.icarus = {
        isNormalUser = true;
        extraGroups = ["wheel" "networkmanager" "seat" "video" "input" "audio"];
        password = "$6$0FVRMTDT.48Unjkz$lu5WVd6hcWLt6qVvODKXpkg.4Wa0RODz7ltVfbrpP73vm.ggSdSdAAfVFXDB5WyctBw81HNsPBZfreXT.BHka1";
      };
      users.users.root.password = "$6$0FVRMTDT.48Unjkz$lu5WVd6hcWLt6qVvODKXpkg.4Wa0RODz7ltVfbrpP73vm.ggSdSdAAfVFXDB5WyctBw81HNsPBZfreXT.BHka1";
      services.openssh.settings.PasswordAuthentication = true;
    };

    homeModule = _: {
    };
  };
}
