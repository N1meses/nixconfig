# Shared by every browser aspect in this directory: the mimeapps table and
# $BROWSER, both keyed off whichever browser set features.compositors.browser.
#
# Deliberately not an aspect. It installs nothing on its own, so making it
# selectable would allow a host to take the MIME table without a browser and
# end up with default-applications pointing at a .desktop that is not in the
# closure. The `_` prefix keeps importTree from ever turning it into a name.
{
  config,
  lib,
  ...
}:
let
  b = config.features.compositors.browser;

  # Everything a browser is expected to claim. Explicit rather than left to
  # association because finix ships no mimeinfo.cache to fall back on.
  webTypes = [
    "text/html"
    "text/xml"
    "application/xhtml+xml"
    "application/vnd.mozilla.xul+xml"
    "application/x-extension-htm"
    "application/x-extension-html"
    "application/x-extension-shtml"
    "application/x-extension-xht"
    "application/x-extension-xhtml"
    "x-scheme-handler/http"
    "x-scheme-handler/https"
    "x-scheme-handler/about"
    "x-scheme-handler/unknown"
    "x-scheme-handler/ftp"
    "x-scheme-handler/chrome"
  ];
in
{
  environment.sessionVariables.BROWSER = lib.mkDefault b.command;

  xdg.mime-apps = {
    default-applications = lib.genAttrs webTypes (_: [ b.desktopFile ]) // {
      "application/pdf" = [ "org.pwmt.zathura.desktop" ];
      "x-scheme-handler/element" = [ "element-desktop.desktop" ];
      "x-scheme-handler/io.element.desktop" = [ "element-desktop.desktop" ];
    };
    added-associations = {
      "text/html" = [ b.desktopFile ];
      "application/pdf" = [ "org.pwmt.zathura.desktop" ];
    };
  };
}
