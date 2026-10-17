# Constants shared by server.sync.host and server.sync.client. Not a module.
{
  hubPath = "/sync";
  user = "sync";
  profile = "sync";

  # Relative to each client's home.
  paths = [
    "Projects"
    "md_files"
    "nixconfig"
    "agents"
    "AGENTS.md"
    "CLAUDE.md"
    "GEMINI.md"
  ];

  # Unison ignore patterns. `Name` matches at any depth, so a real source dir
  # literally called `target` or `result` is not synced either.
  ignore = [
    "Name target"
    "Name result"
    "Name result-*"
    "Name .venv"
    "Name node_modules"
    "Name .direnv"
    "Name .#*"
    "Name #*#"
    "Name *~"
    "Path Projects/c/linux"
    "Path Projects/nix/nixpkgs"
    "Path Projects/nix/home-manager"
    "Path Projects/c/nix"
  ];
}
