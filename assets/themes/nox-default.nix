{
  # Nox Default Theme for Helix - Fixed scope formatting
  # Ported from VSCode Nox Theme by Agamjot-Singh v1.0.4

  nox-default = {
    # SYNTAX HIGHLIGHTING - All keys quoted like dark_plus
    "attribute" = "cyan";
    "comment" = "green";
    "comment.block" = "green";
    "comment.line" = "green";
    "comment.block.documentation" = "doc_green";

    "constant" = "blue";
    "constant.builtin" = "blue";
    "constant.builtin.boolean" = "blue";
    "constant.character" = "orange";
    "constant.character.escape" = "red";
    "constant.numeric" = "pale_green";
    "constant.numeric.integer" = "pale_green";
    "constant.numeric.float" = "pale_green";

    "string" = "orange";
    "string.regexp" = "red";
    "string.special" = "blue";
    "string.special.symbol" = "blue";
    "string.special.path" = "orange";
    "string.special.uri" = "cyan";

    "keyword" = "blue";
    "keyword.control" = "blue";
    "keyword.control.conditional" = "blue";
    "keyword.control.repeat" = "blue";
    "keyword.control.import" = "blue";
    "keyword.control.return" = "blue";
    "keyword.control.exception" = "blue";
    "keyword.directive" = "gray";
    "keyword.function" = "blue";
    "keyword.operator" = "light_gray";
    "keyword.storage" = "blue";
    "keyword.storage.type" = "blue";
    "keyword.storage.modifier" = "blue";

    "operator" = "light_gray";

    "function" = "yellow";
    "function.builtin" = "yellow";
    "function.macro" = "purple";
    "function.method" = "yellow";
    "function.special" = "yellow";

    "variable" = "cyan";
    "variable.builtin" = "blue";
    "variable.parameter" = "cyan";
    "variable.other" = "cyan";
    "variable.other.member" = "cyan";

    "type" = "type_cyan";
    "type.builtin" = "type_cyan";
    "type.enum" = "type_cyan";
    "type.enum.variant" = "light_green";

    "constructor" = "type_cyan";

    "label" = "light_gray2";
    "namespace" = "light_gray2";
    "module" = "light_gray2";

    "property" = "cyan";

    "tag" = "blue";
    "tag.builtin" = "blue";
    "special" = "purple";
    "punctuation" = "text";
    "punctuation.bracket" = "text";
    "punctuation.delimiter" = "text";
    "punctuation.special" = "blue";

    # MARKUP
    "markup.heading" = {
      fg = "blue";
      modifiers = [ "bold" ];
    };
    "markup.heading.1" = {
      fg = "blue";
      modifiers = [ "bold" ];
    };
    "markup.heading.2" = {
      fg = "blue";
      modifiers = [ "bold" ];
    };
    "markup.heading.3" = {
      fg = "blue";
      modifiers = [ "bold" ];
    };
    "markup.heading.4" = {
      fg = "blue";
      modifiers = [ "bold" ];
    };
    "markup.heading.5" = {
      fg = "blue";
      modifiers = [ "bold" ];
    };
    "markup.heading.6" = {
      fg = "blue";
      modifiers = [ "bold" ];
    };
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
      underline = {
        style = "line";
      };
    };
    "markup.link.text" = "cyan";
    "markup.link.label" = "cyan";
    "markup.quote" = "doc_green";
    "markup.raw" = "orange";
    "markup.raw.block" = "orange";
    "markup.raw.inline" = "orange";
    "markup.list" = "list_blue";
    "markup.list.numbered" = "list_blue";
    "markup.list.unnumbered" = "list_blue";

    # DIFF
    "diff.plus" = "diff_green";
    "diff.minus" = "diff_red";
    "diff.delta" = "diff_yellow";
    "diff.plus.gutter" = "diff_green";
    "diff.minus.gutter" = "diff_red";
    "diff.delta.gutter" = "diff_yellow";

    # UI ELEMENTS
    "ui.background" = {
      bg = "background";
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

    "ui.cursor" = {
      bg = "cursor";
      fg = "background";
    };
    "ui.cursor.primary" = {
      bg = "cursor";
      fg = "background";
    };
    "ui.cursor.match" = {
      bg = "cursor_match";
      fg = "cursor_match_fg";
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

    "ui.linenr" = {
      fg = "linenr";
    };
    "ui.linenr.selected" = {
      fg = "linenr_selected";
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

    # DIAGNOSTICS
    "error" = "error";
    "warning" = "warning";
    "info" = "info";
    "hint" = "hint_gray";

    "diagnostic.error" = {
      underline = {
        style = "curl";
        color = "error";
      };
    };
    "diagnostic.warning" = {
      underline = {
        style = "curl";
        color = "warning";
      };
    };
    "diagnostic.info" = {
      underline = {
        style = "curl";
        color = "info";
      };
    };
    "diagnostic.hint" = {
      underline = {
        style = "curl";
        color = "hint_gray";
      };
    };
    "diagnostic.unnecessary" = {
      modifiers = [ "dim" ];
    };
    "diagnostic.deprecated" = {
      modifiers = [ "crossed_out" ];
    };

    # PALETTE
    palette = {
      # Main colors
      white = "#ffffff";
      text = "#d4d4d4";
      text_gray = "#cccccc";
      background = "#0d0d0d";

      # Syntax colors
      green = "#57A64A";
      doc_green = "#6A9955";
      blue = "#569cd6";
      cyan = "#9cdcfe";
      type_cyan = "#4EC9B0";
      yellow = "#DCDCAA";
      orange = "#D69D85";
      red = "#d16969";
      purple = "#BD63C5";
      pale_green = "#b5cea8";
      light_green = "#B8D7A3";
      gray = "#9B9B9B";
      light_gray = "#B4B4B4";
      light_gray2 = "#C8C8C8";
      light_gray3 = "#DADADA";
      dark_gray = "#7F7F7F";
      link_blue = "#3890d1";
      list_blue = "#6796e6";

      # Diff colors
      diff_green = "#81b88b";
      diff_red = "#c74e39";
      diff_yellow = "#e2c08d";

      # UI colors
      cursor = "#aeafad";
      cursor_match = "#515c6a";
      cursor_match_fg = "#74879f";
      selection = "#264f78";
      highlight = "#2a2d2e";
      linenr = "#858585";
      linenr_selected = "#c6c6c6";
      virtual_text = "#404040";
      whitespace = "#e3e4e229";

      # Statusline colors
      statusline_bg = "#040404";
      statusline_inactive_fg = "#cccccc99";
      statusline_inactive_bg = "#3c3c3c99";
      statusline_insert = "#0e4d77";
      statusline_select = "#16825d";

      # Popup/Menu colors
      popup_bg = "#1b1b1b";
      menu_selected = "#062e49";
      window_border = "#5F5F5F";
      scroll = "#79797966";

      # Diagnostic colors
      error = "#f48771";
      warning = "#cca700";
      info = "#75beff";
      hint_gray = "#999999";
    };
  };
}
