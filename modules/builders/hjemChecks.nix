{ lib, config, ... }:
let
  inherit (lib)
    attrValues
    concatMap
    concatMapStringsSep
    filter
    findFirst
    hasSuffix
    mapAttrs'
    nameValuePair
    unique
    ;

  userFiles = user: [
    user.files
    user.xdg.cache.files
    user.xdg.config.files
    user.xdg.data.files
    user.xdg.state.files
  ];

  managedFiles =
    users:
    filter (f: f.enable && f.source != null) (
      concatMap (user: concatMap attrValues (userFiles user)) (attrValues users)
    );

  validators = pkgs: [
    {
      deps = [ pkgs.zsh ];
      match =
        t:
        hasSuffix "/.zshrc" t
        || hasSuffix "/.zshenv" t
        || hasSuffix "/.zprofile" t
        || hasSuffix ".zsh" t;
      run = f: ''
        zsh -n ${f}
        if grep -nP '^\s*(?!function\s)[^\s#()]+\s+[^\s()]+\s*\(\)\s*\{' ${f}; then
          echo "    ^ glued function definition: a config chunk was concatenated without a newline"
          exit 1
        fi
      '';
    }
    {
      deps = [ pkgs.openssh ];
      match = t: hasSuffix "/.ssh/config" t;
      run = f: "ssh -G -F ${f} example.invalid >/dev/null";
    }
    {
      deps = [ pkgs.git ];
      match = t: hasSuffix "/git/config" t || hasSuffix "/.gitconfig" t;
      run = f: "git config --file ${f} --list >/dev/null";
    }
    {
      deps = [ pkgs.niri ];
      match = t: hasSuffix "/niri/config.kdl" t;
      run = f: "niri validate -c ${f} >/dev/null";
    }
    {
      deps = [ pkgs.python3 ];
      match = t: hasSuffix ".toml" t;
      run = f: "python3 -c 'import tomllib,sys; tomllib.load(open(sys.argv[1],\"rb\"))' ${f}";
    }
    {
      deps = [ pkgs.bash ];
      match = t: hasSuffix ".sh" t;
      run = f: "bash -n ${f}";
    }
    {
      deps = [ pkgs.python3 ];
      match =
        t:
        hasSuffix ".ini" t
        || hasSuffix "/mimeapps.list" t
        || hasSuffix "-portals.conf" t
        || hasSuffix "/xdg-desktop-portal-termfilechooser/config" t;
      run =
        f:
        "python3 -c 'import configparser,sys; configparser.ConfigParser(strict=False).read(sys.argv[1])' ${f}";
    }
  ];

  mkCheck =
    name: pkgs: users:
    let
      vs = validators pkgs;
      entries = map (file: {
        inherit file;
        validator = findFirst (v: v.match file.target) null vs;
      }) (managedFiles users);
      active = filter (e: e.validator != null) entries;
    in
    pkgs.runCommand "hjem-check-${name}"
      {
        nativeBuildInputs = unique (concatMap (e: e.validator.deps) active);
      }
      ''
        fail=0
        ${concatMapStringsSep "\n" (e: ''
          echo "checking ${e.file.target}"
          if ! ( ${e.validator.run "${e.file.source}"} ); then
            echo "  FAILED: ${e.file.target}"
            fail=1
          fi
        '') active}
        if [ "$fail" -ne 0 ]; then
          echo "hjem file validation failed for ${name}"
          exit 1
        fi
        echo "validated ${toString (builtins.length active)} files"
        touch $out
      '';
in
{
  checks =
    mapAttrs' (
      name: c: nameValuePair "hjem-${name}" (mkCheck name c.pkgs c.config.hjem.users)
    ) config.finixConfigurations
    // mapAttrs' (
      name: c: nameValuePair "hjem-${name}" (mkCheck name c.pkgs c.config.hjem.users)
    ) config.nixosConfigurations;
}
