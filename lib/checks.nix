{
  lib,
  config,
  pkgs,
  ...
}:
let
  inherit (lib)
    any
    attrValues
    concatMap
    concatMapStringsSep
    concatStringsSep
    elem
    filter
    filterAttrs
    findFirst
    hasInfix
    hasSuffix
    mapAttrs'
    nameValuePair
    unique
    ;

  inherit (config.aspectLib)
    layersOf
    resolve
    usersOf
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
        hasSuffix "/.zshrc" t || hasSuffix "/.zshenv" t || hasSuffix "/.zprofile" t || hasSuffix ".zsh" t;
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
      deps = [ pkgs.openssh ];
      match = t: hasSuffix "/.ssh/authorized_keys" t;
      run = f: "ssh-keygen -l -f ${f} >/dev/null";
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
      match = t: hasInfix "/helix/themes/" t && hasSuffix ".toml" t;
      run = f: ''
        python3 - ${f} <<'EOF'
        import re, sys, tomllib
        theme = tomllib.load(open(sys.argv[1], "rb"))
        palette = theme.get("palette", {})
        hexre = re.compile(r"^#[0-9a-fA-F]{6}([0-9a-fA-F]{2})?$")
        bad = []
        def check(scope, value):
            if not isinstance(value, str):
                return
            if value in palette or hexre.match(value):
                return
            bad.append(f"{scope} -> {value!r}")
        for scope, spec in theme.items():
            if scope == "palette":
                continue
            if isinstance(spec, str):
                check(scope, spec)
            elif isinstance(spec, dict):
                for key in ("fg", "bg"):
                    if key in spec:
                        check(f"{scope}.{key}", spec[key])
                under = spec.get("underline")
                if isinstance(under, dict) and "color" in under:
                    check(f"{scope}.underline.color", under["color"])
        for name, value in palette.items():
            if not hexre.match(value):
                bad.append(f"palette.{name} -> {value!r}")
        if bad:
            print("undefined palette references:", file=sys.stderr)
            for b in bad:
                print("  " + b, file=sys.stderr)
            sys.exit(1)
        print(f"theme ok: {len(theme)-1} scopes, {len(palette)} palette entries")
        EOF
      '';
    }
    {
      deps = [ pkgs.python3 ];
      match = t: hasSuffix ".toml" t;
      run = f: "python3 -c 'import tomllib,sys; tomllib.load(open(sys.argv[1],\"rb\"))' ${f}";
    }
    {
      deps = [ pkgs.python3 ];
      match = t: hasSuffix ".json" t || hasSuffix ".jsonc" t;
      run = f: "python3 -c 'import json,sys; json.load(open(sys.argv[1]))' ${f}";
    }
    {
      deps = [ pkgs.lua ];
      match = t: hasSuffix ".lua" t;
      run = f: "lua -e 'assert(loadfile(\"${f}\"))'";
    }
    {
      deps = [ pkgs.kitty ];
      match = t: hasSuffix "/kitty/kitty.conf" t;
      run = f: "kitty +runpy 'from kitty.config import load_config; load_config(\"${f}\")'";
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

  mkHjemCheck =
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

  inertOn =
    name: host:
    let
      userClosure = concatMap (u: resolve [ u ]) (usersOf "hosts.${name}");
      live =
        n:
        let
          ls = layersOf n;
        in
        ls == [ ] || any (c: elem c ls) host.classes || (elem "home" ls && elem n userClosure);
    in
    filter (n: !(live n)) (resolve [ "hosts.${name}" ]);

  inertReport = lib.concatMapStringsSep "\n" (
    name:
    let
      dead = inertOn name config.hosts.${name};
    in
    if dead == [ ] then "  ${name}: ok" else "  ${name}: ${concatStringsSep " " dead}"
  ) (builtins.attrNames config.hosts);

  anyInert = any (name: inertOn name config.hosts.${name} != [ ]) (builtins.attrNames config.hosts);

  primaryClass = host: builtins.head host.classes;
  buildable = filterAttrs (name: _: config.hosts.${name}.machineModules != [ ]);
in
{
  checks =
    mapAttrs' (name: sys: nameValuePair "nixos-${name}" sys.config.system.build.toplevel) (
      buildable config.nixosConfigurations
    )

    // mapAttrs' (name: sys: nameValuePair "finix-${name}" sys.config.system.build.toplevel) (
      buildable config.finixConfigurations
    )

    // mapAttrs' (
      name: host:
      let
        sys = config.${primaryClass host + "Configurations"}.${name};
      in
      nameValuePair "hjem-${name}" (mkHjemCheck name sys.pkgs sys.config.hjem.users)
    ) config.hosts

    // {
      aspects = pkgs.runCommand "check-aspects-live" { } (
        if anyInert then
          ''
            echo "aspects selected but contributing nothing:"
            cat <<'REPORT'
            ${inertReport}
            REPORT
            echo
            echo "each listed aspect declares slots, but none for that host's classes,"
            echo "and it is not reachable from any of its users."
            exit 1
          ''
        else
          ''
            cat <<'REPORT'
            ${inertReport}
            REPORT
            touch $out
          ''
      );
    };
}
