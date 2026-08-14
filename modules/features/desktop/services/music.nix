{ config, ... }:
{
  aspects.desktop.services.music = {
    description = "MPD music daemon, in the user session, playing through PipeWire.";
    includes = with config.aspectLib.names; [ desktop.compositors.compositors ];
    home =
      { config, pkgs, ... }:
      let
        musicDir = "${config.directory}/Music";
        stateDir = "${config.directory}/.local/state/mpd";
      in
      {
        packages = with pkgs; [
          mpd
          mpc
        ];

        files."Music".type = "directory";
        xdg.state.files."mpd".type = "directory";
        xdg.state.files."mpd/playlists".type = "directory";

        xdg.config.files."mpd/mpd.conf".text = ''
          music_directory     "${musicDir}"
          playlist_directory  "${stateDir}/playlists"
          db_file             "${stateDir}/database"
          state_file          "${stateDir}/state"
          sticker_file        "${stateDir}/sticker.sql"

          auto_update         "yes"
          restore_paused      "yes"

          audio_output {
            type "pipewire"
            name "PipeWire"
          }
        '';

        features.compositors.autoStart = [ "mpd" ];
      };
  };
}
