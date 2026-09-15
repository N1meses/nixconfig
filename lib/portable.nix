{
  lib,
  config,
  ...
}:
let
  inherit (lib)
    attrNames
    concatMap
    filterAttrs
    foldl'
    hasPrefix
    mapAttrsToList
    nameValuePair
    removePrefix
    sort
    ;

  inherit (config.aspectLib) usersOf;

  programs = pkgs: {
    git = {
      package = pkgs.git;
      bin = "git";
      match = n: n == "git/config";
      flags = root: "--set GIT_CONFIG_GLOBAL ${root}/git/config";
    };

    yazi = {
      package = pkgs.yazi;
      bin = "yazi";
      match = hasPrefix "yazi/";
      flags = root: "--set YAZI_CONFIG_HOME ${root}/yazi";
    };

    starship = {
      package = pkgs.starship;
      bin = "starship";
      match = n: n == "starship.toml";
      flags = root: "--set STARSHIP_CONFIG ${root}/starship.toml";
    };

    atuin = {
      package = pkgs.atuin;
      bin = "atuin";
      match = hasPrefix "atuin/";
      flags = root: "--set ATUIN_CONFIG_DIR ${root}/atuin";
    };

    kitty = {
      package = pkgs.kitty;
      bin = "kitty";
      match = hasPrefix "kitty/";
      flags = root: ''--add-flags "--config ${root}/kitty/kitty.conf"'';
    };

    helix = {
      package = pkgs.helix;
      bin = "hx";
      match = hasPrefix "helix/";
      flags = root: "--set XDG_CONFIG_HOME ${root}";
    };
  };

  filesFor =
    user: spec:
    filterAttrs (n: f: f.enable && f.source != null && spec.match n) user.xdg.config.files;

  wrap =
    pkgs: user: userName: progName: spec:
    let
      files = filesFor user spec;
      root = pkgs.linkFarm "${userName}-${progName}-config" (
        mapAttrsToList (name: f: {
          inherit name;
          path = f.source;
        }) files
      );
    in
    pkgs.symlinkJoin {
      name = "${userName}-${progName}";
      paths = [ spec.package ];
      nativeBuildInputs = [ pkgs.makeWrapper ];
      postBuild = ''
        wrapProgram $out/bin/${spec.bin} ${spec.flags root}
      '';
    };

  primaryClass = host: builtins.head host.classes;

  hostForUser = foldl' (
    acc: hostName:
    acc
    // builtins.listToAttrs (
      map (u: nameValuePair (removePrefix "users." u) hostName) (
        builtins.filter (u: !(acc ? ${removePrefix "users." u})) (usersOf "hosts.${hostName}")
      )
    )
  ) { } (sort (a: b: a < b) (attrNames config.hosts));

  wrappersFor =
    userName: hostName:
    let
      host = config.hosts.${hostName};
      sys = config.${primaryClass host + "Configurations"}.${hostName};
      user = sys.config.hjem.users.${userName};
      pkgs = sys.pkgs;
      specs = programs pkgs;
    in
    map (progName: nameValuePair "${userName}-${progName}" (wrap pkgs user userName progName specs.${progName})) (
      builtins.filter (progName: filesFor user specs.${progName} != { }) (attrNames specs)
    );
in
{
  packages = builtins.listToAttrs (
    concatMap (userName: wrappersFor userName hostForUser.${userName}) (attrNames hostForUser)
  );
}
