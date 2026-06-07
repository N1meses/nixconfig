{inputs, ...}: {
  flake.modules.homeManager.opencode = {
    pkgs,
    config,
    ...
  }: {
    programs.opencode = {
      package = inputs.opencode.packages.${pkgs.system}.default;
      enable = true;
      enableMcpIntegration = true;

      settings = {
        theme = "opencode";
        autoupdate = "notify";
        default_agent = "default";

        permission = {
          edit = "ask";
          bash = {
            "rm *" = "ask";
            "sudo *" = "ask";
            "git push*" = "ask";
            "git commit*" = "ask";
            "nixos-rebuild*" = "ask";
            "home-manager*" = "ask";
            "ls" = "allow";
            "cat" = "allow";
            "grep" = "allow";
            "git status" = "allow";
            "git diff" = "allow";
            "git log" = "allow";
            "pwd" = "allow";
            "*" = "ask";
          };
          skill = "ask";
          webfetch = "allow";
          doom_loop = "ask";
          external_directory = "allow";
        };

        share = "manual";

        compaction = {
          auto = true;
          prune = true;
        };

        watcher.ignore = [
          "node_modules/**"
          "dist/**"
          "build/**"
          ".git/**"
          "target/**"
          "result/**"
          ".direnv/**"
          ".ollama/**"
        ];

        formatter = {
          prettier.disabled = false;
          nixfmt.disabled = false;
        };

        tui.diff_style = "auto";

        instructions = ["${config.home.homeDirectory}/AGENTS.md"];

        provider = {
          google = {
            models = {};
          };
        };

        plugin = [
          "opencode-gemini-auth"
          "@franlol/opencode-md-table-formatter"
          "oh-my-opencode"
        ];
      };

      agents = {
        default = ''
          You are a helpful assistant focused on direct, practical solutions.

          Keep responses concise and to the point.
          Prefer simple solutions over complex ones.
          Ask clarifying questions when requirements are unclear.
        '';
      };

      commands = {
        test = ''
          Run the full test suite and report any failures.
          Focus on failing tests and suggest fixes.
        '';
        commit = ''
          Review staged changes and create a well-formatted git commit message.
          Follow conventional commits format.
        '';
        review = ''
          Review the code for:
          - Security issues
          - Performance problems
          - Best practices violations
          - Potential bugs
        '';
      };
    };
  };
}
