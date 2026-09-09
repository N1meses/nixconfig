# Semantic roles. This is the only file where a colour or a modifier is chosen;
# to-helix.nix and to-zed.nix only translate names.
let
  palette = import ./palette.nix;

  roles = {
    # comments
    comment = { fg = "green"; italic = true; };
    docComment = { fg = "doc_green"; italic = true; };

    # literals
    string = { fg = "orange"; };
    number = { fg = "pale_green"; };
    escape = { fg = "red"; };
    constant = { fg = "violet_rose"; };

    # keywords
    keyword = { fg = "blue"; };
    keywordControl = { fg = "blue"; bold = true; };
    keywordModifier = { fg = "blue"; italic = true; };
    preproc = { fg = "slate"; };

    # callables
    function = { fg = "yellow"; bold = true; };
    macro = { fg = "purple"; bold = true; };
    special = { fg = "purple"; };

    # values
    variable = { fg = "cyan"; };
    parameter = { fg = "cyan"; italic = true; };
    selfRef = { fg = "violet"; };
    property = { fg = "aqua"; };

    # types
    type = { fg = "type_cyan"; bold = true; };
    typeBuiltin = { fg = "type_cyan"; italic = true; };
    enumVariant = { fg = "leaf"; };

    # structure
    namespace = { fg = "steel"; };
    label = { fg = "deep_amber"; };
    attribute = { fg = "amber"; };
    tag = { fg = "rose"; };
    operator = { fg = "gray"; };
    punctuation = { fg = "text"; };

    # markup
    heading = { fg = "blue"; bold = true; };
    link = { fg = "cyan"; };
    listMarker = { fg = "list_blue"; };
  };
in
{
  inherit palette roles;
}
