{
  config,
  lib,
  ...
}: let
  cfg = config.features.dev.languages;
in {
  options.features.dev.languages = {
    nix.enable = lib.mkEnableOption "Nix language support";
    java.enable = lib.mkEnableOption "Java language support";
    bash.enable = lib.mkEnableOption "Bash language support";
    python.enable = lib.mkEnableOption "Python language support";
    c.enable = lib.mkEnableOption "C language support";
    css.enable = lib.mkEnableOption "CSS language support";
    go.enable = lib.mkEnableOption "Go language support";
    html.enable = lib.mkEnableOption "HTML language support";
    javascript.enable = lib.mkEnableOption "JavaScript language support";
    json.enable = lib.mkEnableOption "JSON language support";
    lua.enable = lib.mkEnableOption "Lua language support";
    markdown.enable = lib.mkEnableOption "Markdown language support";
    puml.enable = lib.mkEnableOption "PlantUML language support";
    rust.enable = lib.mkEnableOption "Rust language support";
    yaml.enable = lib.mkEnableOption "YAML language support";
    zig.enable = lib.mkEnableOption "Zig language support";
  };

  config = {
    flake.modules.homeManager.languages = {
      lib,
      pkgs,
      ...
    }: {
      imports = with config.flake.modules.homeManager;
        []
        ++ lib.optional cfg.bash.enable bash
        ++ lib.optional cfg.c.enable c
        ++ lib.optional cfg.css.enable css
        ++ lib.optional cfg.go.enable go
        ++ lib.optional cfg.html.enable html
        ++ lib.optional cfg.java.enable java
        ++ lib.optional cfg.javascript.enable javascript
        ++ lib.optional cfg.json.enable json
        ++ lib.optional cfg.lua.enable lua
        ++ lib.optional cfg.markdown.enable markdown
        ++ lib.optional cfg.nix.enable nix
        ++ lib.optional cfg.puml.enable puml
        ++ lib.optional cfg.python.enable python
        ++ lib.optional cfg.rust.enable rust
        ++ lib.optional cfg.yaml.enable yaml
        ++ lib.optional cfg.zig.enable zig;

      programs.helix.languages = {
        language-server = lib.mkMerge [
          (lib.mkIf cfg.nix.enable {
            nixd.command = "${pkgs.nixd}/bin/nixd";
          })
          (lib.mkIf cfg.bash.enable {
            bash-language-server = {
              command = "${pkgs.nodePackages.bash-language-server}/bin/bash-language-server";
              args = ["start"];
            };
          })
          (lib.mkIf cfg.python.enable {
            pyright = {
              command = "${pkgs.pyright}/bin/pyright-langserver";
              args = ["--stdio"];
            };
          })
          (lib.mkIf cfg.rust.enable {
            rust-analyzer.command = "${pkgs.rust-analyzer}/bin/rust-analyzer";
          })
          (lib.mkIf cfg.go.enable {
            gopls.command = "${pkgs.gopls}/bin/gopls";
          })
          (lib.mkIf cfg.java.enable {
            jdtls.command = "${pkgs.jdt-language-server}/bin/jdtls";
          })
          (lib.mkIf cfg.c.enable {
            clangd.command = "${pkgs.clang-tools}/bin/clangd";
          })
          (lib.mkIf cfg.javascript.enable {
            typescript-language-server = {
              command = "${pkgs.nodePackages.typescript-language-server}/bin/typescript-language-server";
              args = ["--stdio"];
            };
          })
          (lib.mkIf cfg.json.enable {
            vscode-json-languageserver = {
              command = "${pkgs.nodePackages.vscode-langservers-extracted}/bin/vscode-json-languageserver";
              args = ["--stdio"];
            };
          })
          (lib.mkIf cfg.html.enable {
            vscode-html-languageserver = {
              command = "${pkgs.nodePackages.vscode-langservers-extracted}/bin/vscode-html-languageserver";
              args = ["--stdio"];
            };
          })
          (lib.mkIf cfg.css.enable {
            vscode-css-languageserver = {
              command = "${pkgs.nodePackages.vscode-langservers-extracted}/bin/vscode-css-languageserver";
              args = ["--stdio"];
            };
          })
          (lib.mkIf cfg.lua.enable {
            lua-language-server.command = "${pkgs.lua-language-server}/bin/lua-language-server";
          })
          (lib.mkIf cfg.markdown.enable {
            marksman = {
              command = "${pkgs.marksman}/bin/marksman";
              args = ["server"];
            };
          })
          (lib.mkIf cfg.yaml.enable {
            yaml-language-server = {
              command = "${pkgs.yaml-language-server}/bin/yaml-language-server";
              args = ["--stdio"];
            };
          })
          (lib.mkIf cfg.zig.enable {
            zls.command = "${pkgs.zls}/bin/zls";
          })
        ];

        language =
          lib.optional cfg.nix.enable {
            name = "nix";
            auto-format = true;
            language-servers = ["nixd"];
            formatter.command = "${pkgs.alejandra}/bin/alejandra";
          }
          ++ lib.optional cfg.bash.enable {
            name = "bash";
            auto-format = true;
            language-servers = ["bash-language-server"];
          }
          ++ lib.optional cfg.python.enable {
            name = "python";
            auto-format = true;
            language-servers = ["pyright"];
          }
          ++ lib.optional cfg.rust.enable {
            name = "rust";
            auto-format = true;
            language-servers = ["rust-analyzer"];
          }
          ++ lib.optional cfg.go.enable {
            name = "go";
            auto-format = true;
            language-servers = ["gopls"];
          }
          ++ lib.optional cfg.java.enable {
            name = "java";
            auto-format = true;
            language-servers = ["jdtls"];
          }
          ++ lib.optional cfg.c.enable {
            name = "c";
            auto-format = true;
            language-servers = ["clangd"];
          }
          ++ lib.optional cfg.c.enable {
            name = "cpp";
            auto-format = true;
            language-servers = ["clangd"];
          }
          ++ lib.optional cfg.javascript.enable {
            name = "javascript";
            auto-format = true;
            language-servers = ["typescript-language-server"];
          }
          ++ lib.optional cfg.javascript.enable {
            name = "typescript";
            auto-format = true;
            language-servers = ["typescript-language-server"];
          }
          ++ lib.optional cfg.json.enable {
            name = "json";
            auto-format = true;
            language-servers = ["vscode-json-languageserver"];
          }
          ++ lib.optional cfg.html.enable {
            name = "html";
            auto-format = true;
            language-servers = ["vscode-html-languageserver"];
          }
          ++ lib.optional cfg.css.enable {
            name = "css";
            auto-format = true;
            language-servers = ["vscode-css-languageserver"];
          }
          ++ lib.optional cfg.lua.enable {
            name = "lua";
            auto-format = true;
            language-servers = ["lua-language-server"];
          }
          ++ lib.optional cfg.markdown.enable {
            name = "markdown";
            auto-format = true;
            language-servers = ["marksman"];
          }
          ++ lib.optional cfg.yaml.enable {
            name = "yaml";
            auto-format = true;
            language-servers = ["yaml-language-server"];
          }
          ++ lib.optional cfg.zig.enable {
            name = "zig";
            auto-format = true;
            language-servers = ["zls"];
          };
      };
    };
  };
}
