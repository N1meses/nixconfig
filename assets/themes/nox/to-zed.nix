let
  inherit (import ./roles.nix) palette roles;

  h =
    key:
    let
      v = palette.${key};
    in
    if builtins.stringLength v == 7 then v + "ff" else v;

  syn =
    name:
    let
      r = roles.${name};
    in
    {
      color = h r.fg;
      font_style = if r.italic or false then "italic" else null;
      font_weight = if r.bold or false then 700 else null;
    };

  c = key: {
    color = h key;
    font_style = null;
    font_weight = null;
  };
in
{
  "$schema" = "https://zed.dev/schema/themes/v0.2.0.json";
  name = "Nox";
  author = "nimeses";
  themes = [
    {
      name = "nox-default";
      appearance = "dark";
      style = {
        background = h "background";
        "border" = h "window_border";
        "border.variant" = h "separator";
        "border.focused" = h "selection";
        "border.selected" = h "selection";
        "border.transparent" = "#00000000";
        "border.disabled" = h "separator";
        "elevated_surface.background" = h "popup_bg";
        "surface.background" = h "popup_bg";
        "element.background" = h "popup_bg";
        "element.hover" = h "highlight";
        "element.active" = h "menu_selected";
        "element.selected" = h "menu_selected";
        "element.disabled" = h "popup_bg";
        "ghost_element.background" = "#00000000";
        "ghost_element.hover" = h "highlight";
        "ghost_element.active" = h "menu_selected";
        "ghost_element.selected" = h "menu_selected";
        "ghost_element.disabled" = "#00000000";
        "drop_target.background" = h "selection";

        text = h "text";
        "text.muted" = h "text_gray";
        "text.placeholder" = h "hint_gray";
        "text.disabled" = h "hint_gray";
        "text.accent" = h "blue";
        icon = h "text";
        "icon.muted" = h "hint_gray";
        "icon.disabled" = h "hint_gray";
        "icon.accent" = h "blue";

        "status_bar.background" = h "background";
        "title_bar.background" = h "background";
        "title_bar.inactive_background" = h "background";
        "toolbar.background" = h "background";
        "tab_bar.background" = h "background";
        "tab.active_background" = h "background";
        "tab.inactive_background" = h "bufferline_bg";
        "panel.background" = h "background";
        "panel.indent_guide" = h "virtual_text";
        "panel.indent_guide_active" = h "linenr";
        "pane.focused_border" = h "selection";
        "pane_group.border" = h "separator";

        "editor.background" = h "background";
        "editor.foreground" = h "cyan";
        "editor.gutter.background" = h "background";
        "editor.line_number" = h "linenr";
        "editor.active_line_number" = h "linenr_selected";
        "editor.active_line.background" = h "cursorline";
        "editor.highlighted_line.background" = h "highlight";
        "editor.invisible" = h "virtual_text";
        "editor.wrap_guide" = h "ruler";
        "editor.active_wrap_guide" = h "linenr";
        "editor.indent_guide" = h "virtual_text";
        "editor.indent_guide_active" = h "linenr";
        "editor.document_highlight.read_background" = h "highlight";
        "editor.document_highlight.write_background" = h "selection";
        "editor.subheader.background" = h "popup_bg";

        "scrollbar.thumb.background" = h "scroll";
        "scrollbar.thumb.border" = h "separator";
        "scrollbar.track.background" = h "background";
        "scrollbar.track.border" = h "background";
        "search.match_background" = h "selection";

        error = h "error";
        warning = h "warning";
        info = h "info";
        hint = h "hint_gray";
        success = h "diff_green";
        predictive = h "virtual_text";
        created = h "diff_green";
        modified = h "diff_yellow";
        deleted = h "diff_red";
        conflict = h "warning";
        ignored = h "hint_gray";
        hidden = h "hint_gray";
        renamed = h "info";
        unreachable = h "hint_gray";

        "terminal.background" = h "background";
        "terminal.foreground" = h "text";
        "terminal.ansi.background" = h "background";
        "terminal.ansi.black" = h "background";
        "terminal.ansi.red" = h "red";
        "terminal.ansi.green" = h "green";
        "terminal.ansi.yellow" = h "yellow";
        "terminal.ansi.blue" = h "blue";
        "terminal.ansi.magenta" = h "purple";
        "terminal.ansi.cyan" = h "type_cyan";
        "terminal.ansi.white" = h "text";
        "terminal.ansi.bright_black" = h "linenr";
        "terminal.ansi.bright_red" = h "error";
        "terminal.ansi.bright_green" = h "leaf";
        "terminal.ansi.bright_yellow" = h "amber";
        "terminal.ansi.bright_blue" = h "cyan";
        "terminal.ansi.bright_magenta" = h "rose";
        "terminal.ansi.bright_cyan" = h "aqua";
        "terminal.ansi.bright_white" = h "white";

        players = [
          {
            cursor = h "cursor";
            selection = h "selection";
            background = h "blue";
          }
        ];

        syntax = {
          "comment" = syn "comment";
          "comment.doc" = syn "docComment";

          "string" = syn "string";
          "string.escape" = syn "escape";
          "string.regex" = syn "escape";
          "string.special" = syn "escape";
          "string.special.symbol" = syn "constant";
          "string.special.path" = syn "string";
          "string.special.url" = syn "link";

          "number" = syn "number";
          "number.float" = syn "number";
          "boolean" = syn "constant";
          "constant" = syn "constant";
          "constant.builtin" = syn "constant";

          "keyword" = syn "keywordControl";
          "keyword.import" = syn "keywordControl";
          "keyword.conditional" = syn "keywordControl";
          "keyword.exception" = syn "keywordControl";
          "keyword.operator" = syn "keyword";
          "preproc" = syn "preproc";
          "operator" = syn "operator";

          "function" = syn "function";
          "function.call" = syn "function";
          "constructor" = syn "type";

          "variable" = syn "variable";
          "variable.member" = syn "property";
          "variable.parameter.builtin" = syn "selfRef";
          "variable.parameter" = syn "parameter";
          "variable.special" = syn "selfRef";
          "property" = syn "property";

          # Zed has no `type.builtin`: `(type (identifier) @type)` tags EVERYTHING in
          # an annotation position, primitives included, so bold there marks `int`
          # and `str` as emphatically as a user class. Helix does distinguish them
          # (its python query carries an explicit builtin list) and keeps bold for
          # complex types - that behaviour is unchanged.
          # Here: plain `type` takes the italic style, while the captures that are
          # unambiguously complex keep bold.
          "type" = syn "typeBuiltin";
          "type.class" = syn "type";
          "enum" = syn "type";
          "variant" = syn "enumVariant";

          "namespace" = syn "namespace";
          "label" = syn "label";
          "attribute" = syn "attribute";
          "tag" = syn "tag";
          "selector" = syn "tag";
          "selector.pseudo" = syn "attribute";
          "embedded" = syn "punctuation";
          "primary" = syn "variable";

          "punctuation" = syn "punctuation";
          "punctuation.bracket" = syn "punctuation";
          "punctuation.delimiter" = syn "punctuation";
          "punctuation.special" = syn "keyword";
          "punctuation.markup" = syn "punctuation";
          "punctuation.list_marker" = syn "listMarker";

          "title" = syn "heading";
          "emphasis" = {
            color = h "text";
            font_style = "italic";
            font_weight = null;
          };
          "emphasis.strong" = {
            color = h "blue";
            font_style = null;
            font_weight = 700;
          };
          "link_text" = syn "link";
          "link_uri" = {
            color = h "link_blue";
            font_style = "italic";
            font_weight = null;
          };
          "text.literal" = syn "string";

          "hint" = c "hint_gray";
          "predictive" = {
            color = h "virtual_text";
            font_style = "italic";
            font_weight = null;
          };
          "diff.plus" = c "diff_green";
          "diff.minus" = c "diff_red";
        };
      };
    }
  ];
}
