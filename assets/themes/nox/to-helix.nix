let
  inherit (import ./roles.nix) palette roles;

  mods =
    r:
    (if r.bold or false then [ "bold" ] else [ ]) ++ (if r.italic or false then [ "italic" ] else [ ]);

  s =
    name:
    let
      r = roles.${name};
      m = mods r;
    in
    if m == [ ] then
      r.fg
    else
      {
        inherit (r) fg;
        modifiers = m;
      };

  curl = colour: {
    underline = {
      style = "curl";
      color = colour;
    };
  };
in
{
  nox-default = {
    "comment" = s "comment";
    "comment.line" = s "comment";
    "comment.block" = s "comment";
    "comment.block.documentation" = s "docComment";

    "string" = s "string";
    "string.regexp" = s "escape";
    "string.special" = s "escape";
    "string.special.symbol" = s "constant";
    "string.special.path" = s "string";
    "string.special.uri" = s "link";

    "constant" = s "constant";
    "constant.builtin" = s "constant";
    "constant.builtin.boolean" = s "constant";
    "constant.character" = s "string";
    "constant.character.escape" = s "escape";
    "constant.numeric" = s "number";
    "constant.numeric.integer" = s "number";
    "constant.numeric.float" = s "number";

    "keyword" = s "keyword";
    "keyword.control" = s "keywordControl";
    "keyword.control.conditional" = s "keywordControl";
    "keyword.control.repeat" = s "keywordControl";
    "keyword.control.import" = s "keywordControl";
    "keyword.control.return" = s "keywordControl";
    "keyword.control.exception" = s "keywordControl";
    "keyword.function" = s "keyword";
    "keyword.storage" = s "keyword";
    "keyword.storage.type" = s "keyword";
    "keyword.storage.modifier" = s "keywordModifier";
    "keyword.directive" = s "preproc";
    # `and` / `or` / `not` / `is` / `in` / `del`. These are words, so they read as
    # keywords; white (the symbol-operator colour) makes them look unstyled.
    "keyword.operator" = s "keyword";

    "operator" = s "operator";

    "function" = s "function";
    "function.builtin" = s "function";
    "function.method" = s "function";
    "function.special" = s "function";
    "function.macro" = s "macro";
    "special" = s "special";

    "variable" = s "variable";
    "variable.other" = s "variable";
    "variable.parameter" = s "parameter";
    "variable.builtin" = s "selfRef";
    "variable.other.member" = s "property";
    "property" = s "property";

    "type" = s "type";
    "type.enum" = s "type";
    "type.builtin" = s "typeBuiltin";
    "type.enum.variant" = s "enumVariant";
    "constructor" = s "type";

    "namespace" = s "namespace";
    "module" = s "namespace";
    "label" = s "label";
    "attribute" = s "attribute";
    "tag" = s "tag";
    "tag.builtin" = s "tag";

    "punctuation" = s "punctuation";
    "punctuation.bracket" = s "punctuation";
    "punctuation.delimiter" = s "punctuation";
    "punctuation.special" = s "keyword";

    "embedded" = "text";

    "markup.heading" = s "heading";
    "markup.heading.1" = s "heading";
    "markup.heading.2" = s "heading";
    "markup.heading.3" = s "heading";
    "markup.heading.4" = s "heading";
    "markup.heading.5" = s "heading";
    "markup.heading.6" = s "heading";
    "markup.heading.marker" = s "punctuation";
    "markup.bold" = {
      fg = "blue";
      modifiers = [ "bold" ];
    };
    "markup.italic" = {
      modifiers = [ "italic" ];
    };
    "markup.strikethrough" = {
      modifiers = [ "crossed_out" ];
    };
    "markup.link.url" = {
      fg = "link_blue";
      underline.style = "line";
    };
    "markup.link.text" = s "link";
    "markup.link.label" = s "link";
    "markup.quote" = s "docComment";
    "markup.raw" = s "string";
    "markup.raw.block" = s "string";
    "markup.raw.inline" = s "string";
    "markup.list" = s "listMarker";
    "markup.list.numbered" = s "listMarker";
    "markup.list.unnumbered" = s "listMarker";

    "diff.plus" = "diff_green";
    "diff.minus" = "diff_red";
    "diff.delta" = "diff_yellow";
    "diff.plus.gutter" = "diff_green";
    "diff.minus.gutter" = "diff_red";
    "diff.delta.gutter" = "diff_yellow";

    "ui.background" = {
      bg = "background";
    };
    "ui.background.separator" = {
      fg = "separator";
    };
    "ui.text" = {
      fg = "text";
    };
    "ui.text.focus" = {
      fg = "white";
    };
    "ui.text.info" = {
      fg = "text_gray";
    };
    "ui.text.inactive" = {
      fg = "hint_gray";
    };
    "ui.text.directory" = {
      fg = "steel";
    };

    "ui.virtual" = {
      fg = "virtual_text";
    };
    "ui.virtual.indent-guide" = {
      fg = "virtual_text";
    };
    "ui.virtual.whitespace" = {
      fg = "whitespace";
    };
    "ui.virtual.inlay-hint" = {
      fg = "hint_gray";
    };
    "ui.virtual.ruler" = {
      bg = "ruler";
    };
    "ui.virtual.wrap" = {
      fg = "virtual_text";
    };
    "ui.virtual.jump-label" = {
      fg = "jump_label";
      modifiers = [ "bold" ];
    };

    "ui.cursor" = {
      bg = "cursor";
      fg = "background";
    };
    "ui.cursor.primary" = {
      bg = "cursor";
      fg = "background";
    };
    "ui.cursor.insert" = {
      bg = "statusline_insert";
      fg = "white";
    };
    "ui.cursor.select" = {
      bg = "statusline_select";
      fg = "white";
    };
    "ui.cursor.match" = {
      bg = "cursor_match";
      fg = "cursor_match_fg";
    };

    "ui.cursorline" = {
      bg = "cursorline";
    };
    "ui.cursorline.primary" = {
      bg = "cursorline";
    };

    "ui.selection" = {
      bg = "selection";
    };
    "ui.selection.primary" = {
      bg = "selection";
    };
    "ui.highlight" = {
      bg = "highlight";
    };

    "ui.gutter" = {
      bg = "background";
    };
    "ui.linenr" = {
      fg = "linenr";
    };
    "ui.linenr.selected" = {
      fg = "linenr_selected";
    };

    "ui.bufferline" = {
      fg = "text_gray";
      bg = "bufferline_bg";
    };
    "ui.bufferline.active" = {
      fg = "white";
      bg = "background";
    };

    "ui.statusline" = {
      fg = "white";
      bg = "statusline_bg";
    };
    "ui.statusline.inactive" = {
      fg = "statusline_inactive_fg";
      bg = "statusline_inactive_bg";
    };
    "ui.statusline.normal" = {
      fg = "white";
      bg = "statusline_bg";
    };
    "ui.statusline.insert" = {
      fg = "white";
      bg = "statusline_insert";
    };
    "ui.statusline.select" = {
      fg = "white";
      bg = "statusline_select";
    };

    "ui.popup" = {
      fg = "text_gray";
      bg = "popup_bg";
    };
    "ui.popup.info" = {
      fg = "text";
      bg = "popup_bg";
    };
    "ui.window" = {
      fg = "window_border";
    };
    "ui.help" = {
      fg = "text_gray";
      bg = "popup_bg";
    };
    "ui.menu" = {
      fg = "text";
      bg = "popup_bg";
    };
    "ui.menu.selected" = {
      fg = "white";
      bg = "menu_selected";
    };
    "ui.menu.scroll" = {
      fg = "scroll";
      bg = "popup_bg";
    };

    "error" = "error";
    "warning" = "warning";
    "info" = "info";
    "hint" = "hint_gray";

    "diagnostic.error" = curl "error";
    "diagnostic.warning" = curl "warning";
    "diagnostic.info" = curl "info";
    "diagnostic.hint" = curl "hint_gray";
    "diagnostic.unnecessary" = {
      modifiers = [
        "dim"
        "italic"
      ];
    };
    "diagnostic.deprecated" = {
      modifiers = [ "crossed_out" ];
    };

    inherit palette;
  };
}
