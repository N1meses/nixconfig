let
  palette = import ./palette.nix;

  roles = {
    comment = {
      fg = "green";
      italic = true;
    };
    docComment = {
      fg = "doc_green";
      italic = true;
    };

    string = {
      fg = "orange";
    };
    number = {
      fg = "pale_green";
    };
    escape = {
      fg = "red";
    };
    constant = {
      fg = "violet_rose";
    };

    keyword = {
      fg = "blue";
      italic = true;
    };
    keywordControl = {
      fg = "blue";
      italic = true;
    };
    keywordModifier = {
      fg = "blue";
      italic = true;
    };
    preproc = {
      fg = "slate";
    };

    function = {
      fg = "yellow";
    };
    macro = {
      fg = "purple";
      bold = true;
    };
    special = {
      fg = "purple";
    };

    variable = {
      fg = "cyan";
    };
    parameter = {
      fg = "cyan";
      italic = true;
    };
    selfRef = {
      fg = "violet";
    };
    property = {
      fg = "cyan";
    };

    type = {
      fg = "type_cyan";
      bold = true;
    };
    typeBuiltin = {
      fg = "type_cyan";
      italic = true;
    };
    enumVariant = {
      fg = "type_cyan";
      bold = true;
    };

    namespace = {
      fg = "steel";
    };
    label = {
      fg = "deep_amber";
    };
    attribute = {
      fg = "amber";
    };
    tag = {
      fg = "rose";
    };
    operator = {
      fg = "white";
    };
    punctuation = {
      fg = "text";
    };

    heading = {
      fg = "blue";
      bold = true;
    };
    link = {
      fg = "cyan";
    };
    listMarker = {
      fg = "list_blue";
    };
  };
in
{
  inherit palette roles;
}
