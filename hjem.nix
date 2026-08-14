let
  self = import ./. { };

  hostname = builtins.replaceStrings [ "\n" ] [ "" ] (builtins.readFile /etc/hostname);

  byUser =
    self.homeConfigurations.${hostname} or (throw "hjem: no homeConfiguration for host '${hostname}'");

  users = builtins.attrNames byUser;
in
if builtins.length users == 1 then
  byUser.${builtins.head users}
else
  throw "hjem: host '${hostname}' has multiple users (${builtins.concatStringsSep ", " users}); select one explicitly, e.g. (import ./.).homeConfigurations.${hostname}.<user>"
