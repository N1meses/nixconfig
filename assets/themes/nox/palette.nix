# Nox palette - raw hues only. No scope names, no modifiers.
#
# Every syntax colour clears 4.5:1 against `background`. Of the 210 syntax
# colour pairs, 9 fall below CIE76 dE 20 and each is accounted for in the
# design doc; the closest genuinely co-occurring pair (function/number, dE 13.0)
# is separated on the modifier channel instead - function is bold.
#
# Do not add a colour here without checking it against the others. See
# 2026-09-09-nox-multi-editor-design.md section 4.
{
  # --- base ---
  white = "#ffffff";
  text = "#d4d4d4";
  text_gray = "#cccccc";
  background = "#0d0d0d";

  # --- syntax: anchors kept from the original nox port ---
  blue = "#569CD6"; # keyword
  yellow = "#DCDCAA"; # function
  type_cyan = "#4EC9B0"; # type
  orange = "#D69D85"; # string
  green = "#57A64A"; # comment
  doc_green = "#6A9955"; # doc comment
  pale_green = "#B5CEA8"; # number
  cyan = "#9CDCFE"; # variable
  purple = "#BD63C5"; # macro / special
  red = "#D16969"; # escape / regex

  # --- syntax: changed or new (design doc section 4.3) ---
  gray = "#9E9E9E"; # operator     (was #B4B4B4, dE 11.6 from punctuation)
  violet_rose = "#B48EAD"; # constant     (was = keyword blue)
  violet = "#A88BE0"; # self/this    (was = keyword blue)
  rose = "#E58AA8"; # tag          (was = keyword blue)
  amber = "#D7BA7D"; # attribute    (was = variable cyan)
  deep_amber = "#C8873C"; # label        (was ~= punctuation grey)
  steel = "#7FB3C8"; # namespace    (was ~= punctuation grey)
  aqua = "#8FD6C4"; # property     (was = variable cyan)
  leaf = "#9FD98A"; # enum variant (was ~= number)
  slate = "#7F8C99"; # preproc      (was #9B9B9B)

  # --- markup / links ---
  link_blue = "#3890d1";
  list_blue = "#6796e6";

  # --- diff ---
  diff_green = "#81b88b";
  diff_red = "#c74e39";
  diff_yellow = "#e2c08d";

  # --- ui ---
  cursor = "#aeafad";
  cursor_match = "#515c6a";
  cursor_match_fg = "#74879f";
  selection = "#264f78";
  highlight = "#2a2d2e";
  cursorline = "#1a1a1a";
  linenr = "#858585";
  linenr_selected = "#c6c6c6";
  virtual_text = "#646464"; # was #404040 - 1.87:1, effectively invisible
  ruler = "#3a3a3a";
  whitespace = "#e3e4e229";
  jump_label = "#ff9e64";

  statusline_bg = "#040404";
  statusline_inactive_fg = "#cccccc99";
  statusline_inactive_bg = "#3c3c3c99";
  statusline_insert = "#0e4d77";
  statusline_select = "#16825d";

  popup_bg = "#1b1b1b";
  menu_selected = "#062e49";
  window_border = "#6B6B6B"; # was #5F5F5F - 3.04:1, borderline
  scroll = "#79797966";
  separator = "#2a2a2a";
  bufferline_bg = "#141414";

  # --- diagnostics ---
  error = "#f48771";
  warning = "#cca700";
  info = "#75beff";
  hint_gray = "#999999";
}
