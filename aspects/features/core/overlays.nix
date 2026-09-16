{ inputs, ... }: {
  aspects.core.overlays = {
    description = "Fleet-wide nixpkgs overlays (pinned CachyOS kernel).";
  };
}
