_: {
  aspects.profile.osint = {
    description = "Self-audit OSINT toolkit: what a stranger can turn up about you from a name, handle or address.";
    home =
      { pkgs, ... }:
      {
        packages = with pkgs; [
          # handle or address -> accounts
          maigret
          sherlock
          holehe
          socialscan
          ghunt

          # frameworks, for anything the one-shot tools miss
          recon-ng
          sn0int

          # attack surface of a domain you own
          amass
          subfinder
          photon

          # metadata in files you have already published, and the counterpart
          exiftool
          mat2

          # credentials leaked into public git history
          gitleaks
          trufflehog
        ];
      };
  };
}
