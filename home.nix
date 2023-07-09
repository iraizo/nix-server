{ config, pkgs, imports, inputs, ... }:


{
  imports = [ inputs.neovim-flake.homeManagerModules.default ];
  home.stateVersion = "23.11";

  programs.neovim-flake = {
	enable = true;

    settings = {
        vim = {
            theme = {
                enable = true;
                name = "catppuccin";
                style = "mocha";
            };
        };
    };
  };
}
